clear; clc; close all

%% Cerinta 1
mdl = 'model2';                                                                       %Crearea fisierului
load_system(mdl)                                                                      %Incarcam in memorie modelul simulink

%% Cerintele 2 si 3
Tmax = 30;                                                                            %Timp de simulare, suficient pentru a intra in regim stationar - 30 de secunde
t = linspace(0, Tmax, 100);                                                           %Orizont de simulare
u = double(t>=0);                                                                     %Intrare treapta - vector de timp
usim = timeseries(u, t);                                                              %Construim structura ce este primita de blocul From Workspace
set_param(mdl, 'Stoptime', num2str(Tmax))                                             %Setam timpul de simulare
out = sim(mdl);                                                                       %Simulam modelul

%Salvam iesirile in variabilele propuse
simout_mat1 = out.y1;
simout_mat2 = out.y2;
simout_fcn1 = out.y_fcn1;
simout_fcn2 = out.y_fcn2;

%Plotam iesirile
figure('Name', 'Grafice pentru verificarea regimului stationar pentru iesirea x');                %Comparam blocurile simulink pentru iesirea theta
subplot(2,1,1);
plot(simout_mat1.time, simout_mat1.data, 'r', 'LineWidth', 2);                                    %Cu rosu plotam iesirea x pentru prima implementare
grid on
xlabel('timp');
ylabel('x');
subplot(2,1,2);
plot(simout_fcn1.time, simout_fcn1.data, 'b', 'LineWidth', 2);                                    %Cu albastru plotam iesirea x pentru a doua implementare
grid on
xlabel('timp');
ylabel('x');
figure('Name', 'Grafice pentru verificarea regimului stationar pentru iesirea theta');            %Comparam blocurile simulink pentru iesirea x
subplot(2,1,1);
plot(simout_mat2.time, simout_mat2.data, 'r', 'LineWidth', 2);                                    %Cu rosu plotam iesirea theta pentru prima implementare
grid on
xlabel('timp');
ylabel('theta');
subplot(2,1,2);
plot(simout_fcn2.time, simout_fcn2.data, 'b', 'LineWidth', 2);                                    %Cu albastru plotam iesirea theta pentru a doua implementare
grid on
xlabel('timp');
ylabel('theta');

%% Cerinta 4
simout_mat1 = simout_mat1.data;
simout_mat2 = simout_mat2.data;
simout_fcn1 = simout_fcn1.data;
simout_fcn2 = simout_fcn2.data;
err1 = norm(abs(simout_mat1 - simout_fcn1));                                     %norma erorii pentru theta
err2 = norm(abs(simout_mat2 - simout_fcn2));                                     %norma erorii pentru x
disp('Eroarea dintre simout_mat1 si simout_fcn1');
disp(err1);
disp('Eroarea dintre simout_mat2 si simout_fcn2');
disp(err2);
%Nu exista discrepante intre cele doua variante de a implementa modelul,
%asa cum era de asteptat, intrucat intre graficele lor nu exista diferente vizibile

%% Cerinta 5
ustar = linspace(0.05, 5, 10);       %Vectorul de amplificari
y1star = zeros(10, 1);               %Valoarea iesirii in regim stationar corespunzatoare lui theta
y2star = zeros(10, 1);               %Valoarea iesirii in regim stationar corespunzatoare lui x

%Generam cele 10 intrari de tip treapta si salvam iesirile pentru fiecare
for i = 1:length(ustar)
    in = ustar(i).*u;
    usim = timeseries(in, t);
    out = sim(mdl);
    simout_mat1 = out.y1;
    simout_mat2 = out.y2;
    y1star(i) = simout_mat1.data(end);
    y2star(i) = simout_mat2.data(end);
end

%Coeficientii polinoamelor de ordin 3 care aproximeaza in sensul celor mai mici patrate
p1 = polyfit(ustar, y1star, 3);
p2 = polyfit(ustar, y2star, 3);

%Plotam iesirile in functie de intrare si cele doua polinoame pe acelasi grafic
upgrid = ustar(1):0.01:ustar(end);
figure('Name', 'Graficul iesirilor in functie de intrare si al aproximarilor');
subplot(2,1,1);
plot(ustar, y1star, 'rx');
hold on
plot(upgrid, polyval(p1, upgrid), 'k--');
grid on
xlabel('u*'), ylabel("y1*")
legend('y1star','aprox')
subplot(2,1,2);
plot(ustar, y2star, 'rx');
hold on
plot(upgrid, polyval(p2, upgrid), 'b--');
grid on
xlabel('u*'), ylabel("y2*")
legend('y2star','aprox')


%% Cerinta 6
%Plotam iesirile in functie de intrare si cele doua polinoame pe acelasi grafic cu noul ustar
alfa = 0.05;
beta = 2.5;
gamma = 5.0;
figure('Name', 'Graficul cu cu noul ustar folosind alfa, beta si gamma');
subplot(2,1,1);
plot(ustar, y1star, 'xk');
hold on
plot([alfa, beta, gamma], polyval(p1, [alfa, beta, gamma]), 'k--');
grid on
xlabel('u*'), ylabel("y1*")
legend('y1star','aprox')
subplot(2,1,2);
plot(ustar, y2star, 'xk');
hold on
plot([alfa, beta, gamma], polyval(p2, [alfa, beta, gamma]), 'b--');
grid on
xlabel('u*'), ylabel("y2*")
legend('y2star','aprox')

%% Cerinta 7
%Am creat modelul "model2_inout.slx" asemanator celui de la cerinta 1,
%singura diferenta fiind inlocuirea blocurilor "From Workspace" si 
% "To Workspace" cu blocurile "Input" si "Output"

%% Cerinta 8
u0 = ustar(1);                                                                  %Valoarea intrarii pentru care se determina PSF
[xstarr, ustarr, ystarr, ~] = trim("model2_inout", [], u0, [], [], 1, []);      %Determinam PSF
err = norm(abs(ustarr - u0));
disp('Eroarea dintre ustarr si u0');
disp(err);
%Nu exista discrepante intre cele doua valori,
%asa cum era de asteptat, intrucat in functia trim am setat ca intrarea sa 
%fie fixata

%% Cerinta 9
[A_lin, B_lin, C_lin, D_lin] = linmod("model2_inout", xstarr, ustarr);          %Liniarizare in PSF anterior

%% Cerinta 10
vp = eig(A_lin)
%Sistemul liniarizat este stabil intrucat valorile proprii ale lui ale
%A_lin au partea reala negativa

%% Cerinta 11
mdl = 'model2_linresp';                                                         %Crearea fisierului
load_system(mdl)                                                                %Incarcam in memorie modelul simulink
usim = timeseries(u, t);                                                        %Construim structura ce este primita de blocul From Workspace
set_param(mdl, 'StopTime', num2str(Tmax))                                       %Setam timpul de simulare
out = sim(mdl);                                                                 %Simulam modelul
y_lin = out.y_lin;                                                              %Salvam raspunsul liniar

%% Cerinta 12
y_nl = out.y_nl;                                                                %Salvam raspunsul neliniar
err = norm(reshape(y_lin.data, [1, 62]) - reshape(y_nl.data, [1,62]), 'inf');
disp('Eroarea dintre iesirea liniara si iesirea neliniara');
disp(err);

%% Cerinta 13
[b, a] = ss2tf(A_lin, B_lin, C_lin, D_lin);
H_lin = tf(b, a);
Te = 0.09;                                                                                  %Perioada de esantionare de 0.04s
H_disc = c2d(H_lin, Te, 'tustin');                                                          %Discretizarea sistemului liniarizat
%Am ales aproximarea Tustin intrucat sistemul este stabil, asa cum am aratat
%la cerinta 10. Aproximarea Tustin plaseaza polii stabili ai sistemului 
%continuu in polii stabili ai sistemului discret (in interiorul discului
%unitate). Astfel, si sistemul discretizat va fi stabil.

%% Cerinta 14
[A_disc, B_disc, C_disc, D_disc] = tf2ss(H_disc.numerator{1,1}, H_disc.denominator{1,1});    %Reprezentarea pe stare a sistemului
mdl = 'model2_disc';                                                                         %Crearea fisierului
Tmax = 100;                                                                                  %Marim timpul de simulare de la 30 la 100 secunde
load_system(mdl)                                                                             %Incarcam in memorie modelul simulink
set_param(mdl, 'StopTime', num2str(Tmax))                                                    %Setam timpul de simulare
u = ustarr.*double(t>=0);                                                                    %Intrarea treapta de amplificare ustarr
usim = timeseries(u, t);
out = sim(mdl);

%% Cerinta 15
figure('Name', 'Grafice pentru sistemul neliniar si sistemul discret');
subplot(2,1,1);
plot(out.y_disc.time, out.y_disc.data, 'r');                                                 %Cu rosu plotam iesirea theta pentru sistemul discret
grid on
xlabel('timp');
ylabel('theta');
subplot(2,1,2);
plot(out.y_nl.time, out.y_nl.data, 'b', 'LineWidth', 2);                                     %Cu albastru plotam iesirea theta pentru sistemul neliniar
grid on
xlabel('timp');
ylabel('theta');