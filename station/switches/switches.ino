// The five input buttons
const int pin_check    = 3;
const int pin_button_A = 4;
const int pin_button_0 = 5;
const int pin_button_a = 6;
const int pin_button_p = 7;

// The two output leds
const int pin_inactive = 9;
const int pin_active   = 10;

const int BUTTON_check = 0;
const int BUTTON_A = 1;
const int BUTTON_0 = 2;
const int BUTTON_a = 3;
const int BUTTON_p = 4;

int buttons[] = {
  LOW, LOW, LOW, LOW, LOW};


int active = true;

void setup() {                
  pinMode(pin_check,    INPUT);
  pinMode(pin_button_A, INPUT);
  pinMode(pin_button_0, INPUT);
  pinMode(pin_button_a, INPUT);
  pinMode(pin_button_p, INPUT);
  pinMode(pin_inactive, OUTPUT);
  pinMode(pin_active,   OUTPUT);
  Serial.begin(9600);
}

void loop() {
  read_input();
  monitor();
  transition();
  signal();
}

void read_input() {
  buttons[BUTTON_check] = digitalRead(pin_check);
  buttons[BUTTON_A] = digitalRead(pin_button_A);
  buttons[BUTTON_0] = digitalRead(pin_button_0);
  buttons[BUTTON_a] = digitalRead(pin_button_a);
  buttons[BUTTON_p] = digitalRead(pin_button_p);
}

void monitor() {
  Serial.print(buttons[BUTTON_check]);
  Serial.print(buttons[BUTTON_A]);
  Serial.print(buttons[BUTTON_0]);
  Serial.print(buttons[BUTTON_a]);
  Serial.print(buttons[BUTTON_p]);
  Serial.println();
}

void transition() {
  if (switching() && active) {
    if (active_code_is(HIGH, LOW, HIGH, LOW)) {
      deactivate();
    }
  }
  if (switching() && !active) {
    if (active_code_is(HIGH, HIGH, HIGH, HIGH)) {
      activate();
    }
  }
}

boolean switching() {
  return buttons[BUTTON_check] == HIGH;
}

boolean active_code_is(int value_A, int value_0, int value_a, int value_p) {
  return buttons[BUTTON_A] == value_A && buttons[BUTTON_0] == value_0 && buttons[BUTTON_a] == value_a && buttons[BUTTON_p] == value_p;
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
  digitalWrite(pin_inactive, LOW);
  digitalWrite(pin_active, HIGH);
}

void signal_dead() {
  digitalWrite(pin_inactive, HIGH);
  digitalWrite(pin_active, LOW);
}


