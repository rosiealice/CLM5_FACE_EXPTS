template = '/glade/p/cesm/cseg/inputdata/lnd/clm2/paramdata/clm5_params.c171017.nc'

varnames(1:16) = {'null'}

varnames(17:21)={'k_nitr_max','denitrif_respiration_coefficient','denitrif_respiration_exponent','denitrif_nitrateconc_coefficient','denitrif_nitrateconc_exponent'}

defaults(17:21) = [ 0.1 0.1 1.3 1.15 0.57]
dir = 'namelists'

mult(:,17)=[0.1 0.5 2  4] %perecm. 1 is the default. 
mult(:,18)=[0.1 0.5 2  4] 
mult(:,19)=[0.1 0.5 2  4] 
mult(:,20)=[0.1 0.5 2  4] 
mult(:,21)=[0.1 0.5 2  4] 

formatspec = '%.4f'
vchoose = 17:21
for i=1:4
for vr=vchoose

  new_var =  defaults(vr) .* mult(i,vr)
  namefile = strcat(dir,'/','namelist','PI',char(num2str(vr)),char(num2str(i)))
  copyfile('namelists/defaultnl',namefile)
  textnl = strcat(char(varnames(vr)),char('='),char(num2str(new_var)))
  textnl

  matrix1={char(varnames(vr))}
  matrix2=new_var

  writetable(cell2table([matrix1 num2cell(matrix2)]),namefile,'writevariablenames',0)
end
end