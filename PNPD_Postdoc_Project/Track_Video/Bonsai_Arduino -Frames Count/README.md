# FRAMES COUNTER TO SYNCHRONIZE VIDEOS WITH ELECTROPHYSIOLOGICAL RECORDS

Through BONSAI software (https://bonsai-rx.org/) we receive a "FRAME" number in a 10-digit "string" (without \ r \ n) in a 9600 BaudRate
(Bonsai does not appear to be able to program the "SerialStringWrite" function with another BaudRate).<br />

A digital output (PWM) must be chosen to "FLIP" at each nFrames transition. That is, the pin is nFrames high and nFrames low, oscillating at each frame collected and saved.<br />

Authors: <br />
Flávio Afonso Gonçalves Mourão - mourao.fg@gmail.com<br />
Márcio Flávio Dutra Moraes - mfdm@icb.ufmg.br <br />
24/04/2019

Bonsai - Ref. paper:
https://www.frontiersin.org/articles/10.3389/fninf.2015.00007/full

