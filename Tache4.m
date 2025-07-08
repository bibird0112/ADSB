%% Tâche 4

clear 
clc
close all

fe = 20e6;
Te = 1/fe;

Ts = 1e-6;
fs = 1/Ts;
Fse = Ts/Te;
Nb = 256;
p1 = mod_PPM(1,Fse);
p1_top = p1(1:Fse/2);
t=0:1:(Fse/2)-1;
v0 = trapz(t, abs(p1_top).^2);



simulate_teb_ppmT4_complex_2(Ts,Te,v0);

