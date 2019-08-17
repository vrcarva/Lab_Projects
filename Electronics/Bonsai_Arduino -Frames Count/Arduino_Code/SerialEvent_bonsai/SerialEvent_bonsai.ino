/* CONTADOR DE FRAMES PARA O PAREAMENTE DE REGISTROS EEG
 * Um programa feito do fundo do meu coração junto com o Flávio 
 *
 * 
 * Através do sofware BONSAI 2.3 (https://bonsai-rx.org/) recebe-se o número do "FRAME" em uma "string" de 10 dígitos (sem \r\n) em um BaudRate 
 * de 9600. Aparentemente o Bonsai não permite programar a função SerialStringWrite com
 * outro BaudRate a não ser 9600.
 * 
 * Uma saida digital (PWM) deve escolhida para "FLIP" a cada transição de nFrames. Ou seja, o pino fica nFrames
 * em alta e nFrames em baixa, oscilando a cada frame coletado e salvo.
 * 
 * Marcio Moraes e Flavio Mourao
 * No dia 24/4/2019 - NNC no Computador da filha do Mazoni
 */

int nFrames=10;   // Define o numero de "frames" a ser salvo
int iCount=0;    // Armazenará o frame coletado
char Buffer[20]; // Buffer para o "string". Só precisa de dez, mas sou exagerado mesmo

void setup()
{
  pinMode(10,OUTPUT); // Define o Pino digital
  Serial.begin(9600); // BaudRate
}

void loop()
{
if (Serial.available()>0) // Condicao: confere apenas se o sinal esta chegando
  {
    Serial.readBytes(Buffer,10);   // O sistema sempre monta 10 chars: saida=saida+ " "*(10-len(saida));
    iCount=String(Buffer).toInt(); // Converte o "string" coletado em um "integer" na variavel iCount
    if((iCount%nFrames)==0) digitalWrite(10,(iCount/nFrames)%2); // Condicao: Apenas se for um multiplo inteiro de nFrames 
                                                                 // (neste caso, a resto da divisao deste múltiplo por 2 sera igual 0 ou 1, o que define o estado do pino ("High" ou "Low")
  }

  //
}
