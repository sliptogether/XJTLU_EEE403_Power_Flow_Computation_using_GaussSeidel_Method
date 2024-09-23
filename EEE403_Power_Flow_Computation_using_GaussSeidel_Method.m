% User Input for Power Flow Analysis
prompt = {'Power Input at Bus 1 [p.u.]:', 'Z_12 Impedance [p.u.]:', ...
          'Z_13 Impedance [p.u.]:', 'Z_23 Impedance [p.u.]:', ...
          'Load at Bus 2 [p.u.]:', 'Load at Bus 3 [p.u.]:', ...
          'Initial Voltage at Bus 2 [p.u.]:', 'Initial Voltage at Bus 3 [p.u.]:', ...
          'System Base MVA [p.u.]:'
         };
dlg_title = 'Power Flow Analysis'; 
num_lines = 1;
defaultans = {'1.05+0i','0.02+0.04i','0.01+0.03i','0.0125+0.025i','256.6+110.2i','138.6+45.2i','1+0i','1+0i','100'};
answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

% Extract User Inputs
v1 = str2num(answer{1});              % Power Input at Bus 1
z12 = str2num(answer{2});             % Impedance between Bus 1 and 2
z13 = str2num(answer{3});             % Impedance between Bus 1 and 3
z23 = str2num(answer{4});             % Impedance between Bus 2 and 3
lb2 = str2num(answer{5});             % Load at Bus 2
lb3 = str2num(answer{6});             % Load at Bus 3
v2 = str2num(answer{7});              % Initial Voltage at Bus 2
v3 = str2num(answer{8});              % Initial Voltage at Bus 3
pubase = str2num(answer{9});          % System Base MVA

% Convert Impedances to Admittances
y12 = 1 / z12;
y13 = 1 / z13;
y23 = 1 / z23;

% Convert Loads to Per-Unit System
s2 = (-1) * (lb2 / pubase);
s3 = (-1) * (lb3 / pubase);

% Extract Real and Imaginary Components of Load
p2 = real(s2);
q2 = imag(s2);
p3 = real(s3);
q3 = imag(s3);

% Bus Admittance Matrix
Ybus = [(y12+y13) -y12 -y13; 
        -y12 (y12+y23) -y23; 
        -y13 -y23 (y13+y23)];

% Gauss-Seidel Iteration for Voltage Calculation
tol = 1e-7;
while max(abs([v2 v3] - [v2e v3e])) > tol
    v2e = ((p2 - q2 * i) / conj(v2) + y12 * v1 + y23 * v3) / (y12 + y23);
    v3e = ((p3 - q3 * i) / conj(v3) + y13 * v1 + y23 * v2) / (y13 + y23);
    v2 = v2e;
    v3 = v3e;
end

% Calculate Power Flows and Losses
s1 = v1 * (v1 * (y12 + y13) - (y12 * v2 + y13 * v3));
i12 = y12 * (v1 - v2);
i13 = y13 * (v1 - v3);
i23 = y23 * (v2 - v3);
s12 = v1 * conj(i12);
s13 = v1 * conj(i13);
s23 = v2 * conj(i23);
s21 = v2 * conj(-i12);
s31 = v3 * conj(-i13);
s32 = v3 * conj(-i23);
Sl12 = s12 + s21;
Sl13 = s13 + s31;
Sl23 = s23 + s32;

% Plot Voltage Magnitudes and Power Losses
figure;
subplot(2,1,1);
bar([abs(v1) abs(v2) abs(v3)]);
title('Voltage Magnitudes at Buses');
xlabel('Bus Number');
ylabel('Voltage [p.u.]');
xticks([1 2 3]);
xticklabels({'Bus 1', 'Bus 2', 'Bus 3'});

subplot(2,1,2);
bar([abs(Sl12) abs(Sl13) abs(Sl23)]);
title('Line Power Losses');
xlabel('Line');
ylabel('Power Loss [p.u.]');
xticks([1 2 3]);
xticklabels({'Line 12', 'Line 13', 'Line 23'});

% Display Results
disp('Bus Admittance Matrix:');
disp(Ybus);
disp(['V2 Voltage = ' num2str(v2)]);
disp(['V3 Voltage = ' num2str(v3)]);
disp(['S1 Power = ' num2str(s1)]);
disp(['Line12 loss = ' num2str(Sl12)]);
disp(['Line13 loss = ' num2str(Sl13)]);
disp(['Line23 loss = ' num2str(Sl23)]);
