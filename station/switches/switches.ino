// The five input buttons
int check    = 3;
int button_A = 4;
int button_0 = 5;
int button_a = 6;
int button_p = 7;

int ch = LOW;
int bA = LOW;
int b0 = LOW;
int ba = LOW;
int bp = LOW;

// The two output leds
int inactive_signal = 9;
int active_signal   = 10;

int active = true;

void setup() {                
  pinMode(check,    INPUT);
  pinMode(button_A, INPUT);
  pinMode(button_0, INPUT);
  pinMode(button_a, INPUT);
  pinMode(button_p, INPUT);
  pinMode(inactive_signal, OUTPUT);
  pinMode(active_signal,   OUTPUT);
  Serial.begin(9600);
}

void loop() {
  read_input();
  monitor();
  transition();
  signal();
}

void read_input() {
  ch = digitalRead(check);
  bA = digitalRead(button_A);
  b0 = digitalRead(button_0);
  ba = digitalRead(button_a);
  bp = digitalRead(button_p);
}

void monitor() {
  Serial.print(ch);
  Serial.print(bA);
  Serial.print(b0);
  Serial.print(ba);
  Serial.print(bp);
  Serial.println();
}

void transition() {
  if (ch == HIGH) {
    if (bA == HIGH && b0 == LOW && ba == HIGH && bp == LOW) {
      active = false;
    }
  }
}

void signal() {
  if (active) {
    signal_live();
  } 
  else {
    signal_dead();
  }
}

void signal_live() {
  digitalWrite(inactive_signal, LOW);
  digitalWrite(active_signal, HIGH);
}

void signal_dead() {
  digitalWrite(inactive_signal, HIGH);
  digitalWrite(active_signal, LOW);
}

