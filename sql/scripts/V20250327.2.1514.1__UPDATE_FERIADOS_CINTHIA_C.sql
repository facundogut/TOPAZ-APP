EXECUTE('
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 2 AND DIA = 15;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 2 AND DIA = 16;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 4 AND DIA = 1;   
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 4 AND DIA = 2;   
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 5 AND DIA = 24;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 6 AND DIA = 21;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 8 AND DIA = 16;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 10 AND DIA = 8;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 10 AND DIA = 11; 
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 11 AND DIA = 22; 
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 12 AND DIA = 24; 
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2021 AND MES = 12 AND DIA = 31; 
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 1 AND DIA = 3;   
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 2 AND DIA = 28;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 4 AND DIA = 14;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 4 AND DIA = 15;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 5 AND DIA = 18;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 6 AND DIA = 17;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 6 AND DIA = 20;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 7 AND DIA = 10;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 8 AND DIA = 15;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 9 AND DIA = 12;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 10 AND DIA = 10;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2022 AND MES = 11 AND DIA = 21;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2023 AND MES = 2 AND DIA = 20;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2023 AND MES = 2 AND DIA = 21;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2023 AND MES = 4 AND DIA = 6;   
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2023 AND MES = 4 AND DIA = 7;   
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2023 AND MES = 5 AND DIA = 26;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2023 AND MES = 6 AND DIA = 19;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2023 AND MES = 6 AND DIA = 20;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2023 AND MES = 8 AND DIA = 21;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2023 AND MES = 10 AND DIA = 13;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2023 AND MES = 10 AND DIA = 16;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2023 AND MES = 11 AND DIA = 20;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2024 AND MES = 2 AND DIA = 12;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2024 AND MES = 2 AND DIA = 13;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2024 AND MES = 3 AND DIA = 28;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2024 AND MES = 3 AND DIA = 29;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2024 AND MES = 4 AND DIA = 1;   
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2024 AND MES = 6 AND DIA = 17;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2024 AND MES = 6 AND DIA = 20;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2024 AND MES = 6 AND DIA = 21;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2024 AND MES = 10 AND DIA = 11;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2024 AND MES = 11 AND DIA = 18;  
DELETE FROM dbo.feriados
WHERE PAIS = 0 AND ANIO = 2024 AND MES = 12 AND DIA = 24;
')

EXECUTE('
Update feriados set anio = 0 where anio= 2025 and mes = 3 and dia = 24;
Update feriados set anio = 0 where anio= 2025 and mes = 4 and dia = 2;
Update feriados set anio = 0 where anio= 2025 and mes = 7 and dia = 9;
Update feriados set anio = 0 where anio= 2025 and mes = 12 and dia = 8;

insert into feriados values(0,0,2021,2,15,''Carnaval'','''',-1,-1);
insert into feriados values(0,0,2021,2,16,''Carnaval'','''',-1,-1);
insert into feriados values(0,0,2021,4,1,''Jueves Santo'','''',-1,-1);
insert into feriados values(0,0,2021,4,2,''Dia Vet.Caidos Malvinas/Viernes Santo'','''',-1,-1);
insert into feriados values(0,0,2021,5,24,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2021,6,21,''Paso a la inmortalidad del Gral Martín M. Guemes'','''',-1,-1);
insert into feriados values(0,0,2021,8,16,''Paso a la inmortalidad del General San Martin'','''',-1,-1);
insert into feriados values(0,0,2021,10,8,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2021,10,11,''Dia Respeto a la diversidad cultural'','''',-1,-1);
insert into feriados values(0,0,2021,11,22,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2021,12,24,''Comunicado 51020 BCRA'','''',-1,-1);
insert into feriados values(0,0,2021,12,31,''Comunicado 51020 BCRA'','''',-1,-1);
insert into feriados values(0,0,2022,1,3,''Carnaval'','''',-1,-1);
insert into feriados values(0,0,2022,2,28,''Carnaval'','''',-1,-1);
insert into feriados values(0,0,2022,4,14,''Jueves Santo'','''',-1,-1);
insert into feriados values(0,0,2022,4,15,''Viernes Santo'','''',-1,-1);
insert into feriados values(0,0,2022,5,18,''Censo Nacional de Poblacion'','''',-1,-1);
insert into feriados values(0,0,2022,6,17,''Paso a la inmortalidad del Gral Martín M. Guemes'','''',-1,-1);
insert into feriados values(0,0,2022,6,20,''Paso a la inmortalidad del General Manuel Belgrano'','''',-1,-1);
insert into feriados values(0,0,2022,7,10,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2022,8,15,''Paso a la inmortalidad del General San Martin'','''',-1,-1);
insert into feriados values(0,0,2022,9,12,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2022,10,10,''Dia Respeto a la diversidad cultural'','''',-1,-1);
insert into feriados values(0,0,2022,11,21,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2023,2,20,''Carnaval'','''',-1,-1);
insert into feriados values(0,0,2023,2,21,''Carnaval'','''',-1,-1);
insert into feriados values(0,0,2023,4,6,''Jueves Santo'','''',-1,-1);
insert into feriados values(0,0,2023,4,7,''Viernes Santo'','''',-1,-1);
insert into feriados values(0,0,2023,5,26,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2023,6,19,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2023,6,20,''Paso a la inmortalidad del General Manuel Belgrano'','''',-1,-1);
insert into feriados values(0,0,2023,8,21,''Paso a la inmortalidad del General San Martin'','''',-1,-1);
insert into feriados values(0,0,2023,10,13,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2023,10,16,''Día del Respeto a la Diversidad Cultural'','''',-1,-1);
insert into feriados values(0,0,2023,11,20,'' Día de la Soberanía Nacional'','''',-1,-1);
insert into feriados values(0,0,2024,2,12,''Carnaval'','''',-1,-1);
insert into feriados values(0,0,2024,2,13,''Carnaval'','''',-1,-1);
insert into feriados values(0,0,2024,3,28,''Jueves Santo'','''',-1,-1);
insert into feriados values(0,0,2024,3,29,''Viernes Santo'','''',-1,-1);
insert into feriados values(0,0,2024,4,1,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2024,6,17,''Paso a la inmortalidad del Gral Martín M. Guemes'','''',-1,-1);
insert into feriados values(0,0,2024,6,20,''Paso a la inmortalidad del General Manuel Belgrano'','''',-1,-1);
insert into feriados values(0,0,2024,6,21,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2024,10,11,''Día no laborable con fin turístico'','''',-1,-1);
insert into feriados values(0,0,2024,11,18,''Día de la Soberanía Nacional'','''',-1,-1);
insert into feriados values(0,0,2024,12,24,''Asueto Navidad'','''',-1,-1);
')
