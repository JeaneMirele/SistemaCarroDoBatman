#include <Arduino.h>
#include <WiFi.h>
#include <ESP32Servo.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// --- CONFIGURAÇÕES ---
#define WIFI_SSID "Planta no chão"
#define WIFI_PASSWORD "lindacasa"
#define DATABASE_URL "carrobatman-iot-default-rtdb.firebaseio.com"
#define API_KEY "AIzaSyDtcdWmAQbqkdzEbFKBEqSD8kiD9w_8cks"

// --- OBJETOS ---
FirebaseData fbdo;       // Leitura
FirebaseData fbdoEnvio;  // Envio
FirebaseAuth auth;
FirebaseConfig config;

// --- PINOS ---
#define LED_CABINE 2
#define LED_TURBO 4
#define FAROL1 18
#define FAROL2 19
#define RE1 21
#define RE2 22

#define ENA 14
#define IN1 26
#define IN2 27
#define IN3 25
#define IN4 33
#define ENB 32

#define PIN_TRIG 5
#define PIN_ECHO_ULTRASONICO 34
#define PIN_BUZZER 23
#define PIN_SERVO 13

Servo servoCabine;

// --- ESTADO DO CARRO ---
struct CarroState {
    double destinoX = 0;
    double destinoY = 0;
    double joystickX = 0;
    double joystickY = 0;
    double latRef = 0.0;
    double lngRef = 0.0;
    bool ignicao = false;
    bool cabineAberta = false;
    bool farol = false;      // Variável de controle do farol
    bool stealth = false;
    bool turbo = false;
    String modoDirecao = "manual";
} estado;

// --- VARIÁVEIS DE NAVEGAÇÃO ---
unsigned long sendDataPrevMillis = 0;
double posX = 0.0;
double posY = 0.0;
double anguloAtualSimulado = PI / 2; // Começa apontando para o Norte (90 graus)
const float K_GIRO = 150.0;          // Força da curva
const int DISTANCIA_MINIMA = 20;
bool signupOK = false;

// --- FUNÇÕES AUXILIARES ---

void tocarSom(int freq, int duracao) {
    tone(PIN_BUZZER, freq, duracao);
    delay(duracao);
    noTone(PIN_BUZZER);
}

void emitirSons() {
    static bool ignAnterior = false;
    static bool turboAnterior = false;

    if (estado.ignicao && !ignAnterior) { tocarSom(500, 150); delay(50); tocarSom(800, 300); }
    ignAnterior = estado.ignicao;

    if (estado.turbo && !turboAnterior) { tocarSom(1200, 100); tocarSom(1500, 200); }
    turboAnterior = estado.turbo;

    // Som de Ré
    if (estado.ignicao && estado.joystickY < -0.5 && estado.modoDirecao == "manual") {
        static unsigned long delayRe = 0;
        if (millis() - delayRe > 500) { tocarSom(600, 100); delayRe = millis(); }
    }
}

void controlarCabine() {
    servoCabine.write(estado.cabineAberta ? 90 : 0);
    digitalWrite(LED_CABINE, estado.cabineAberta ? HIGH : LOW);
}

float lerDistancia() {
    digitalWrite(PIN_TRIG, LOW); delayMicroseconds(2);
    digitalWrite(PIN_TRIG, HIGH); delayMicroseconds(10);
    digitalWrite(PIN_TRIG, LOW);
    long dur = pulseIn(PIN_ECHO_ULTRASONICO, HIGH);
    if (dur == 0) return 999;
    return dur * 0.034 / 2;
}

void moverMotores(int velEsq, int velDir) {
    if (velEsq > 0) { digitalWrite(IN1, LOW); digitalWrite(IN2, HIGH); }
    else if (velEsq < 0) { digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW); }
    else { digitalWrite(IN1, LOW); digitalWrite(IN2, LOW); }
    analogWrite(ENA, abs(velEsq));

    if (velDir > 0) { digitalWrite(IN3, LOW); digitalWrite(IN4, HIGH); }
    else if (velDir < 0) { digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW); }
    else { digitalWrite(IN3, LOW); digitalWrite(IN4, LOW); }
    analogWrite(ENB, abs(velDir));
}

// --- SETUP ---
void setup() {
    Serial.begin(115200);

    // Pinos
    pinMode(ENA, OUTPUT); pinMode(IN1, OUTPUT); pinMode(IN2, OUTPUT);
    pinMode(ENB, OUTPUT); pinMode(IN3, OUTPUT); pinMode(IN4, OUTPUT);
    pinMode(PIN_TRIG, OUTPUT); pinMode(PIN_ECHO_ULTRASONICO, INPUT);
    pinMode(PIN_BUZZER, OUTPUT);
    pinMode(LED_CABINE, OUTPUT); pinMode(LED_TURBO, OUTPUT);
    pinMode(FAROL1, OUTPUT); pinMode(FAROL2, OUTPUT);
    pinMode(RE1, OUTPUT); pinMode(RE2, OUTPUT);

    servoCabine.attach(PIN_SERVO); servoCabine.write(0);

    // Conexão
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("Conectando WiFi");
    while (WiFi.status() != WL_CONNECTED) { Serial.print("."); delay(300); }
    Serial.println("\nConectado");

    config.api_key = API_KEY;
    config.database_url = DATABASE_URL;
    if (Firebase.signUp(&config, &auth, "", "")) signupOK = true;

    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);
}

// --- LOOP ---
void loop() {
    if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 100)) {
        sendDataPrevMillis = millis();

        // 1. LER COMANDOS
        if (Firebase.RTDB.getJSON(&fbdo, "/carro")) {
            FirebaseJson &json = fbdo.jsonObject();
            FirebaseJsonData data;

            json.get(data, "joystickX"); if (data.success) estado.joystickX = data.to<double>();
            json.get(data, "joystickY"); if (data.success) estado.joystickY = data.to<double>();
            json.get(data, "destinoX"); if (data.success) estado.destinoX = data.to<double>();
            json.get(data, "destinoY"); if (data.success) estado.destinoY = data.to<double>();
            json.get(data, "ignicao"); if (data.success) estado.ignicao = data.to<bool>();
            json.get(data, "luz"); if (data.success) estado.cabineAberta = data.to<bool>();
            json.get(data, "farol"); if (data.success) estado.farol = data.to<bool>(); // Lendo variável farol
            json.get(data, "stealth"); if (data.success) estado.stealth = data.to<bool>();
            json.get(data, "turbo"); if (data.success) estado.turbo = data.to<bool>();
            json.get(data, "modoDirecao"); if (data.success) estado.modoDirecao = data.to<String>();

            // --- LÓGICA DE RESET POR GPS ---
            double latLida = 0;
            double lngLida = 0;

            // Tenta ler as novas coordenadas do Firebase
            json.get(data, "latRef"); if (data.success) latLida = data.to<double>();
            json.get(data, "lngRef"); if (data.success) lngLida = data.to<double>();

            // Se as coordenadas mudaram (comparação com margem de erro pequena para double)
            if (abs(latLida - estado.latRef) > 0.0000001 || abs(lngLida - estado.lngRef) > 0.0000001) {
                Serial.println(">>> NOVA REFERÊNCIA GPS DETECTADA: RESETANDO POSIÇÃO E ORIENTAÇÃO <<<");

                // Atualiza a memória
                estado.latRef = latLida;
                estado.lngRef = lngLida;

                // Reseta a Odometria Virtual
                posX = 0.0;
                posY = 0.0;
                
                // Reseta orientação para NORTE (90 graus ou PI/2 radianos)
                anguloAtualSimulado = PI / 2;
                
                tocarSom(1000, 500); // Bip longo para avisar que resetou
            }
        }

        // 2. ATUADORES
        controlarCabine();
        emitirSons();
        
        // --- CONTROLE DE ILUMINAÇÃO ATUALIZADO ---
        if (!estado.ignicao || estado.stealth) {
            // Se Ignição OFF ou Stealth ON -> TUDO APAGADO (Prioridade de Segurança)
             digitalWrite(FAROL1, LOW); 
             digitalWrite(FAROL2, LOW); 
             digitalWrite(RE1, LOW); 
             digitalWrite(RE2, LOW); 
             digitalWrite(LED_TURBO, LOW);
        } else {
             // Modo NORMAL (Ignição ON e Stealth OFF)
             
             // Faróis agora obedecem ao botão do APP
             digitalWrite(FAROL1, estado.farol ? HIGH : LOW); 
             digitalWrite(FAROL2, estado.farol ? HIGH : LOW); 
             
             digitalWrite(LED_TURBO, estado.turbo ? HIGH : LOW);
             
             // Luz de Ré continua automática pelo Joystick
             if (estado.joystickY < -0.1) { digitalWrite(RE1, HIGH); digitalWrite(RE2, HIGH); } 
             else { digitalWrite(RE1, LOW); digitalWrite(RE2, LOW); }
        }

        // 3. ENVIO SENSOR
        float dist = lerDistancia();
        Firebase.RTDB.setFloatAsync(&fbdoEnvio, "/carro/obstaculoDistance", dist);

        // 4. MOVIMENTO
        int pwmEsq = 0, pwmDir = 0;
        int velocidadeBase = estado.turbo ? 255 : 200;

        if (estado.ignicao && !estado.cabineAberta) {
            if (estado.modoDirecao == "manual") {
                float x = estado.joystickX; float y = estado.joystickY;
                if (dist < DISTANCIA_MINIMA && y > 0 && !estado.stealth) {
                    moverMotores(0, 0);
                    if (!estado.turbo) { moverMotores(-255, -255); delay(500); moverMotores(255, -255); delay(650); }
                    else { moverMotores(-255, -255); delay(500); moverMotores(255, -255); delay(500); }
                    moverMotores(0, 0);
                } else {
                    pwmEsq = constrain((y + x) * velocidadeBase, -255, 255);
                    pwmDir = constrain((y - x) * velocidadeBase, -255, 255);
                    if (abs(pwmEsq) < 45) pwmEsq = 0; if (abs(pwmDir) < 45) pwmDir = 0;
                }
            } else {
                // Modo AUTOMÁTICO COM CURVAS
                double dx = estado.destinoX - posX;
                double dy = estado.destinoY - posY;
                double distAlvo = sqrt(dx * dx + dy * dy);

                if (distAlvo > 5) {
                    double anguloDesejado = atan2(dy, dx);
                    double erroAngulo = anguloDesejado - anguloAtualSimulado;

                    while (erroAngulo > PI) erroAngulo -= 2 * PI;
                    while (erroAngulo < -PI) erroAngulo += 2 * PI;

                    int correcao = erroAngulo * K_GIRO;
                    pwmEsq = constrain(velocidadeBase - correcao, -255, 255);
                    pwmDir = constrain(velocidadeBase + correcao, -255, 255);

                    anguloAtualSimulado += erroAngulo * 0.1;
                    posX += cos(anguloAtualSimulado) * 2.0;
                    posY += sin(anguloAtualSimulado) * 2.0;
                } else {
                    pwmEsq = pwmDir = 0;
                }
            }
        }
        moverMotores(pwmEsq, pwmDir);
    }
}