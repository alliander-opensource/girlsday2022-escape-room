// The input buttons
const int pin_a = 2;
const int pin_b = 3;
const int pin_c = 4;
const int pin_d = 5;
const int pin_e = 6;

// The output led
const int pin_success = 12;


const int INPUT_a = 0;
const int INPUT_b = 1;
const int INPUT_c = 2;
const int INPUT_d = 3;
const int INPUT_e = 4;

int buttons[] = {
  LOW, LOW, LOW, LOW, LOW};


int active = false;

void setup() {                
  pinMode(pin_a, INPUT);
  pinMode(pin_b, INPUT);
  pinMode(pin_c, INPUT);
  pinMode(pin_d, INPUT);
  pinMode(pin_e, INPUT);
  pinMode(pin_success, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  read_input();
  monitor();
  transition();
  signal();
}

void read_input() {
  buttons[INPUT_a] = digitalRead(pin_a);
  buttons[INPUT_b] = digitalRead(pin_b);
  buttons[INPUT_c] = digitalRead(pin_c);
  buttons[INPUT_d] = digitalRead(pin_d);
  buttons[INPUT_e] = digitalRead(pin_e);
}

void monitor() {
  Serial.print(buttons[INPUT_a]);
  Serial.print(buttons[INPUT_b]);
  Serial.print(buttons[INPUT_c]);
  Serial.print(buttons[INPUT_d]);
  Serial.print(buttons[INPUT_e]);
  Serial.println();
}

void transition() {
  if (active_code_is(HIGH, HIGH, LOW, HIGH, LOW)) {
    activate();
  } else {
    deactivate();
  }
}

boolean active_code_is(int value_a, int value_b, int value_c, int value_d, int value_e) {
  return buttons[INPUT_a] == value_a && buttons[INPUT_b] == value_b && buttons[INPUT_c] == value_c && buttons[INPUT_d] == value_d && buttons[INPUT_e] == value_e;
}

void deactivate() {
  active = false;
}

void activate() {
  active = true;
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
  digitalWrite(pin_success, HIGH);
}

void signal_dead() {
  digitalWrite(pin_success, LOW);
}


