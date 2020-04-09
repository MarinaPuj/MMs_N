close all
clear all
clc
%% AD. Carla Navarro, Marina Pujol y Alvaro Quispe

%% 2. M/M/s//N
%Cua amb únics N clients possibles i s servidors. Quan un client ha estat servit es calcula a partir del seu temps final de sortida el seu nou temps d'entrada

lambda=30; %deben repararse 1 cada 30 días
mu=3; % una reparación tarda 3 días
s=2; % nº de servidores: 2 técnicos
N=5;% población de 5 avionetes disponibles
n=20;

%Creem una taula per guardar les dades. 
%Numero de files=n+N. S'escull l'avioneta que primer arriba independentment de si acaba de ser arreglada o no.
%Les últimes N avionetes a servir (com totes) poden ser la mateixa/repetir-se o no i llavors calcularem els següents temps d'arribada de les N avionetes següents per saber quin es el cas
%Necessitem N espais extres per poder calcular els següents N arrival times
 
for i=1:n+N
    t(i,1)=i;
    zero(i,1)=0;
end

noms={'Num_Repair','Plane','Arrival_Time','Server','Time_Service_Begins','Time_Service_Ends','Service_Time','Wq','W','Idle_Time'};
T=table(t,zero,zero,zero,zero,zero,zero,zero,zero,zero,'VariableNames', noms);

%Per cadascuna de les N avionetes tenim:
for i=1:N
    T.Arrival_Time(i)=exprnd(lambda); %El temps d'arribada.
    T.Plane(i)=i; %El número d'avioneta
    Arrivals(1,i)=T.Arrival_Time(i); %Vector que sempre tindrà dimensió N. Arrivals guarda el temps d'arribada de cada avioneta que no ha estat servida encara de manera ordenada. Quan la avioneta x s'arregli es ficarà el següent arrival time a Arrivals(x).
end

lliures=ones(1,s); %Els servidors lliures son els igual a 1. Si estan ocupats 0.Vector que sempre tindrà dimensió s. 
serv_end=zeros(1,s); %Temps d'acabar de servir de cada servidor. Al principi no han començat =0. Vector que sempre tindrà dimensió s. 
queue=(1:N); %Vector que sempre tindrà dimensió N. Guarda en ordre d'avionetes el Num_Repair de les avionetes que s'han d'arreglar. Exemple: si la primera avioneta que serveixo es la 2, la queue ara serà [1 6 3 4 5], ja que el seu nou lloc a la taula serà el 6.

%Quan començem, serv_end és tot 0s i lliures tot 1s (encara no s'ha servit a ningú),després es van servint clients fins que serv_end no conté cap 0 (tots els servidors han servit mínim una persona). 
%Normalment això passarà quan el numero de clients servits=N+1, ja que lliures es va omplint-se de 0s. Però en el cas que arribi la mateixa avioneta primer més d'un cop tots els servidors haurien d'estar lliures. Per això, no té sentit calcular en un for anterior (per separat) els clients servits des de 1 fins a s.

%Iterem fins a haver servit a n clients. 
for servits=1:n
    
    [minimo, plane] = min(Arrivals); %Trobem l'avioneta que ha arribat primer
    i=queue(plane); %i és el Num_Repair de l'avioneta (numero de fila a la taula).
    
    %Calculem els servidors que estan lliures. Iterem al llarg dels servidors
    for ii=1:s
       if (T.Arrival_Time(i)>= serv_end(ii))  %Si el temps de fi de l'últim client servit pel servidor ii (serv_end(ii)) és més petit que el temps d'arribada del client i -> el servidor està lliure
           lliures(ii)=1;
       else
           lliures(ii)=0;
       end
    end
    
    %{
    disp(i);
    disp(plane);
    disp(round(Arrivals));
    disp(queue);
    disp(lliures);
    disp(serv_end);
    %}
    
    %CAS1: si hi ha algún servidor lliure
    if (sum(lliures)~=0)  
        %Calcular a quin servidor anirà a parar.
        a=rand; %número random entre 0 i 1
        pos=0; 
        if (sum(lliures)==1) %si només hi ha un servidor lliure anirà al lliure
            pos=1; 
        elseif(a==1) %si la a=1 anirà a l'últim servidor lliure
            pos=sum(lliures);
        else 
            %Per tenir la mateixa probabilitat d'anar a cada servidor: multipliquem a per el nombre de servidors lliures i eliminem els decimals(no arrodonim), desprès l'hi sumem 1. 
            %Exemple: 2 servidors lliures ·si a<0.5, pos=a*2 0<=pos<1, pos=0, pos=1; ·si 0.5<=a<1 1<=pos<2, pos=1, pos=2.
          pos=a*sum(lliures); 
          pos=floor(pos);
          pos=pos+1;
        end
        k=find(lliures==1); %Índexs de servidors lliures
        T.Server(i)=k(pos); %Guardem el servidor que l'atendrà
        T.Time_Service_Begins(i)=T.Arrival_Time(i); %Només arribar serà servit ja que hi ha algún servidor lliure.
        T.Service_Time(i)=exprnd(mu);
        T.Idle_Time(i)=T.Arrival_Time(i)-serv_end(k(pos)); %El servidor descansa des que marxa l'últim client fins que arriba aquest.
        T.Time_Service_Ends(i)=T.Time_Service_Begins(i)+ T.Service_Time(i);
        T.Wq(i)=0; %No hi ha cua perquè hi ha un servidor lliure
        T.W(i)=T.Service_Time(i);
        
    %CAS2: Cap servidor està lliure
    else
        [minim, serv] = min(serv_end); %Serà atés pel servidor que acabi primer (el que tingui serv_end més petit)
        T.Time_Service_Begins(i)=minim; %Començarà a ser servit quan el servidor acabi
        T.Server(i)=serv; %Guardem el número de servidor.
        T.Idle_Time(i)=0; %El servidor no descansarà
        T.Service_Time(i)=exprnd(mu);
        T.Time_Service_Ends(i)=T.Time_Service_Begins(i)+ T.Service_Time(i);
        T.Wq(i)=T.Time_Service_Begins(i)-T.Arrival_Time(i);
        T.W(i)=T.Wq(i)+T.Service_Time(i);
    end

    serv_end(T.Server(i))=T.Time_Service_Ends(i); %Guardem el temps en que el servidor acaba de servir a l'usuari i.
    
    next=find(T.Plane==0,1); %Buscar el següent lloc disponible a la taula T
    queue(plane)=next; %Guardar el Num_Repair de l'avioneta al lloc de la queue corresponent. Ex: Si he servit a l'avioneta 2 i el següent lloc de la taula buit és el 30 -> next=30 i queue(2)=30
    T.Arrival_Time(next)=T.Time_Service_Ends(i)+ exprnd(lambda); %Tornem a calcular el temps estimat d'arribada d'aquesta avioneta
    Arrivals(1,plane)=T.Arrival_Time(next); %Guardem el Temps d'arribada a Arrivals. Ex: Si el següent temps estimat d'arribada de l'avioneta 2 és 22s Arrivals(2)=22
    T.Plane(next)=plane; %Guardem el número d'avioneta a la següent.
end

%En el cas de voler incloure el idle time final del tècnic que ha acabat abans: (Temps que espera a que acabi l'altre tècnic)
%{ 
%Final idle time: temps de descans dels servidors que no shan utilitzat perque ja havien acabat mentre lúltim acabava.
[finaltime,m]=max(serv_end);
mm=n+1;
for i=1:s
    if(i~=m) 
        z={0,0,0,0,0,0,0,0,0,0};
        T=[T;z]; %Afegir a la Taula T una fila amb el numero del servidor i el Time Idle extra.
        T.Server(mm)=i;
        T.Idle_Time(mm)=finaltime-serv_end(i);
        mm=mm+1;
    end
end
%}

%Creem una taula per cada servidor.
k1=find(T.Server==1); %Índexs de la taula T de clients que van al servidor 1
k2=find(T.Server==2); %Índexs de la taula T de clients que van al servidor 2
S1=T(k1,:);
S2=T(k2,:);
%Ordenar les taules en ordre ascendent d'arribada.
S1 = sortrows(S1,'Time_Service_Begins','ascend');
S2 = sortrows(S2,'Time_Service_Begins','ascend');

%% Porcentaje de tiempo que un determinado técnico está libre

%Temps lliure del servidor x / Temps final total.
finaltime=max(serv_end);
temps_lliure_total=sum(T.Idle_Time);
temps_lliure_tecnic_1=sum(S1.Idle_Time);
temps_lliure_tecnic_2=sum(S2.Idle_Time);

Perc_tecnic_1=temps_lliure_tecnic_1/finaltime;
Perc_tecnic_2=temps_lliure_tecnic_2/finaltime;
Mitja_Perc=0.5*Perc_tecnic_1+0.5*Perc_tecnic_2;

disp(Perc_tecnic_1);
disp(Perc_tecnic_2);
disp(Mitja_Perc);
        

        
        
    






