close all
clear all
clc
%% AD. Carla Navarro, Marina Pujol y Alvaro Quispe

%% 2. M/M/s//N
%Cua amb �nics N clients possibles i s servidors. Quan un client ha estat servit es calcula a partir del seu temps final de sortida el seu nou temps d'entrada

lambda=30; %deben repararse 1 cada 30 d�as
mu=3; % una reparaci�n tarda 3 d�as
s=2; % n� de servidores: 2 t�cnicos
N=5;% poblaci�n de 5 avionetes disponibles
n=20;

%Creem una taula per guardar les dades. 
%Numero de files=n+N. S'escull l'avioneta que primer arriba independentment de si acaba de ser arreglada o no.
%Les �ltimes N avionetes a servir (com totes) poden ser la mateixa/repetir-se o no i llavors calcularem els seg�ents temps d'arribada de les N avionetes seg�ents per saber quin es el cas
%Necessitem N espais extres per poder calcular els seg�ents N arrival times
 
for i=1:n+N
    t(i,1)=i;
    zero(i,1)=0;
end

noms={'Num_Repair','Plane','Arrival_Time','Server','Time_Service_Begins','Time_Service_Ends','Service_Time','Wq','W','Idle_Time'};
T=table(t,zero,zero,zero,zero,zero,zero,zero,zero,zero,'VariableNames', noms);

%Per cadascuna de les N avionetes tenim:
for i=1:N
    T.Arrival_Time(i)=exprnd(lambda); %El temps d'arribada.
    T.Plane(i)=i; %El n�mero d'avioneta
    Arrivals(1,i)=T.Arrival_Time(i); %Vector que sempre tindr� dimensi� N. Arrivals guarda el temps d'arribada de cada avioneta que no ha estat servida encara de manera ordenada. Quan la avioneta x s'arregli es ficar� el seg�ent arrival time a Arrivals(x).
end

lliures=ones(1,s); %Els servidors lliures son els igual a 1. Si estan ocupats 0.Vector que sempre tindr� dimensi� s. 
serv_end=zeros(1,s); %Temps d'acabar de servir de cada servidor. Al principi no han comen�at =0. Vector que sempre tindr� dimensi� s. 
queue=(1:N); %Vector que sempre tindr� dimensi� N. Guarda en ordre d'avionetes el Num_Repair de les avionetes que s'han d'arreglar. Exemple: si la primera avioneta que serveixo es la 2, la queue ara ser� [1 6 3 4 5], ja que el seu nou lloc a la taula ser� el 6.

%Quan comen�em, serv_end �s tot 0s i lliures tot 1s (encara no s'ha servit a ning�),despr�s es van servint clients fins que serv_end no cont� cap 0 (tots els servidors han servit m�nim una persona). 
%Normalment aix� passar� quan el numero de clients servits=N+1, ja que lliures es va omplint-se de 0s. Per� en el cas que arribi la mateixa avioneta primer m�s d'un cop tots els servidors haurien d'estar lliures. Per aix�, no t� sentit calcular en un for anterior (per separat) els clients servits des de 1 fins a s.

%Iterem fins a haver servit a n clients. 
for servits=1:n
    
    [minimo, plane] = min(Arrivals); %Trobem l'avioneta que ha arribat primer
    i=queue(plane); %i �s el Num_Repair de l'avioneta (numero de fila a la taula).
    
    %Calculem els servidors que estan lliures. Iterem al llarg dels servidors
    for ii=1:s
       if (T.Arrival_Time(i)>= serv_end(ii))  %Si el temps de fi de l'�ltim client servit pel servidor ii (serv_end(ii)) �s m�s petit que el temps d'arribada del client i -> el servidor est� lliure
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
    
    %CAS1: si hi ha alg�n servidor lliure
    if (sum(lliures)~=0)  
        %Calcular a quin servidor anir� a parar.
        a=rand; %n�mero random entre 0 i 1
        pos=0; 
        if (sum(lliures)==1) %si nom�s hi ha un servidor lliure anir� al lliure
            pos=1; 
        elseif(a==1) %si la a=1 anir� a l'�ltim servidor lliure
            pos=sum(lliures);
        else 
            %Per tenir la mateixa probabilitat d'anar a cada servidor: multipliquem a per el nombre de servidors lliures i eliminem els decimals(no arrodonim), despr�s l'hi sumem 1. 
            %Exemple: 2 servidors lliures �si a<0.5, pos=a*2 0<=pos<1, pos=0, pos=1; �si 0.5<=a<1 1<=pos<2, pos=1, pos=2.
          pos=a*sum(lliures); 
          pos=floor(pos);
          pos=pos+1;
        end
        k=find(lliures==1); %�ndexs de servidors lliures
        T.Server(i)=k(pos); %Guardem el servidor que l'atendr�
        T.Time_Service_Begins(i)=T.Arrival_Time(i); %Nom�s arribar ser� servit ja que hi ha alg�n servidor lliure.
        T.Service_Time(i)=exprnd(mu);
        T.Idle_Time(i)=T.Arrival_Time(i)-serv_end(k(pos)); %El servidor descansa des que marxa l'�ltim client fins que arriba aquest.
        T.Time_Service_Ends(i)=T.Time_Service_Begins(i)+ T.Service_Time(i);
        T.Wq(i)=0; %No hi ha cua perqu� hi ha un servidor lliure
        T.W(i)=T.Service_Time(i);
        
    %CAS2: Cap servidor est� lliure
    else
        [minim, serv] = min(serv_end); %Ser� at�s pel servidor que acabi primer (el que tingui serv_end m�s petit)
        T.Time_Service_Begins(i)=minim; %Comen�ar� a ser servit quan el servidor acabi
        T.Server(i)=serv; %Guardem el n�mero de servidor.
        T.Idle_Time(i)=0; %El servidor no descansar�
        T.Service_Time(i)=exprnd(mu);
        T.Time_Service_Ends(i)=T.Time_Service_Begins(i)+ T.Service_Time(i);
        T.Wq(i)=T.Time_Service_Begins(i)-T.Arrival_Time(i);
        T.W(i)=T.Wq(i)+T.Service_Time(i);
    end

    serv_end(T.Server(i))=T.Time_Service_Ends(i); %Guardem el temps en que el servidor acaba de servir a l'usuari i.
    
    next=find(T.Plane==0,1); %Buscar el seg�ent lloc disponible a la taula T
    queue(plane)=next; %Guardar el Num_Repair de l'avioneta al lloc de la queue corresponent. Ex: Si he servit a l'avioneta 2 i el seg�ent lloc de la taula buit �s el 30 -> next=30 i queue(2)=30
    T.Arrival_Time(next)=T.Time_Service_Ends(i)+ exprnd(lambda); %Tornem a calcular el temps estimat d'arribada d'aquesta avioneta
    Arrivals(1,plane)=T.Arrival_Time(next); %Guardem el Temps d'arribada a Arrivals. Ex: Si el seg�ent temps estimat d'arribada de l'avioneta 2 �s 22s Arrivals(2)=22
    T.Plane(next)=plane; %Guardem el n�mero d'avioneta a la seg�ent.
end

%En el cas de voler incloure el idle time final del t�cnic que ha acabat abans: (Temps que espera a que acabi l'altre t�cnic)
%{ 
%Final idle time: temps de descans dels servidors que no shan utilitzat perque ja havien acabat mentre l�ltim acabava.
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
k1=find(T.Server==1); %�ndexs de la taula T de clients que van al servidor 1
k2=find(T.Server==2); %�ndexs de la taula T de clients que van al servidor 2
S1=T(k1,:);
S2=T(k2,:);
%Ordenar les taules en ordre ascendent d'arribada.
S1 = sortrows(S1,'Time_Service_Begins','ascend');
S2 = sortrows(S2,'Time_Service_Begins','ascend');

%% Porcentaje de tiempo que un determinado t�cnico est� libre

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
        

        
        
    






