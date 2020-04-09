# M/M/s//N

Simulació d'una cua amb N clients possibles (únics) i s servidors. Es serviran un total de n clients.

Quan arriba un client:
* Si tots els servidors estan plens anirà al que acabi abans.
* Si hi ha un servidor buit anirà al servidor buit
* Si hi ha més d'un servidor buit té la mateixa probabilitat d'acabar a qualsevol servidor buit.

Al final en una taula T, es mostrarà de cada client servit:
* Número de client servit. 'Num_Repair' (entre 1 i n)
* Número de client possible. 'Plane' (entre 1 i N)
* Temps d'arribada. 'Arrival_Time'
* Quin servidor el serveix. 'Server' (entre 1 i s)
* Temps en que es comença a servir. 'Time_Service_Begins'
* Temps en que s'acaba de servir. 'Time_Service_Ends'
* Temps que ha tardat en servir-se. 'Service_Time'
* Temps que ha estat a la cua. 'Wq'
* Temps total al sistema. 'W'
* Temps de descans del servidor. 'Idle_Time'
