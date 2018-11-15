
%copy default 20tr co2 file here

newfilename='co2_datm_ORNL_ELEV.nc'
oldfilename='co2_datm_1765-2007_c100614.nc'
copyfile('/glade/p/cesmdata/cseg/inputdata/atm/datm7/CO2/fco2_datm_1765-2007_c100614.nc', oldfilename)


copyfile('co2_datm_1765-2007_c100614.nc',newfilename)

co2=ncread(newfilename,'CO2');
time=ncread(newfilename,'time');

ornlfile='/glade/u/home/rfisher/FACE_expt/PTCLM/mydatafiles/co2_ornl_newformat_elev.nc'
%copy ORNL co2 file here

co2_ORNL_elev=ncread(ornlfile,'CO2');
time_ORNL_elev=ncread(ornlfile,'time');

co2s=squeeze(co2);
times=squeeze(time);
co2_ORNL_elevs=squeeze(co2_ORNL_elev);
time_ORNL_elevs=squeeze(time_ORNL_elev);

figure
plot(times,co2s,'r.');hold on
plot(time_ORNL_elevs,co2_ORNL_elevs,'g.');hold on

ncwrite(newfilename,'CO2',co2_ORNL_elev)
ncwrite(newfilename,'time',time_ORNL_elev)

