Data Sources:
1.	All raw CTD and bottle data for I08S were downloaded from https://cchdo.ucsd.edu/cruise/33RR20070204
2.	All raw CTD and bottle data for I09N were downloaded from 
https://cchdo.ucsd.edu/cruise/33RR20070322 
3.	The raw DNA_ID were derived from the "I8I9_2007" tab from the "CLIVAR_DNALOG_CARLSON2019_with_DNA_ids" file.

General Notes:
The cast types for I8S were from trace metal (TM) and regular (R) casts. The I9N samples were all from TM casts. 

I8S TM casts
Since there are no niskin numbers provided in the TM cast data, we manually add niskin numbers counting sequentially in reverse from x (e.g., 12) to y (e.g., 1) assuming niskin x is the shallowest depth and y is the deepest depth at each station. This is done so we can concatenate the cruise id (i.e., I8S, I9N), station number (e.g., S11), and niskin id (e.g., N12) to match with DNA_ID provided by Carlson lab.

This assumption was verified by cross checking the corresponding target CTD pressure provided by Carlson lab for each DNA_ID and calculated depth from that CTD pressure against the reported “DEPTH” in the TM cast data. The linear trend in the graph shows the assumption is correct but the target Carlson pressure matches more closely with TM “DEPTH” with the range for differences between the two values being (0.7 – 11.4). Since CTD instrumentation does not record depth, it is likely that the reported data in the TM cast file was not actually depth but instead the CTD pressure. Hence, we are considering that “DEPTH” value to be the actual recorded CTD pressure and calculating the final depth based off that value and latitude.   

** Major issue with I8S TM casts is that the bottle data from R casts don't match up with sampled depths so we won't have all metadata (e.g., nutrients, T, S). We obtain the CTD temperature, salinity, and oxygen by rounding TM casts recorded CTD pressure to the closest even integer and matching with corresponding CTD pressure from each station’s profile but that's also not the most complete dataset. **

I8S R casts
Station 45 was sampled from the regular cast so we have all associated bottle (e.g., nutrients) metadata for this singular cast. The target Carlson CTD pressure and recorded CTD pressure with each corresponding DNA_ID were close in value and the difference between the two values similarly ranged from 5.6 – 7.4. We use the recorded CTD pressure to calculate the final depth. 

I9N TM casts
Similar to I8S TM casts, there are no niskin numbers, so we have replicated the same workflow for the I9N samples. Again, the reported “DEPTH” values on the TM casts are likely the recorded CTD pressure as reflected by the linear trend between this value and the target Carlson CTD pressure: range of differences = 1.1 – 14.4. We will similarly assume that the depth provided on the TM casts are actually the recorded CTD pressures and have calculated the depth based off this and latitudes.  

** Major issue with I9N TM casts is that the bottle data from R casts don't match up with sampled depths so we won't have all metadata (e.g., nutrients, T, S). We obtain the CTD temperature, salinity, and oxygen by rounding TM casts recorded CTD pressure to the closest even integer and matching with corresponding CTD pressure from each station’s profile but that's also not the most complete dataset. **

Final Merged Product
This contains the relevant date, latitude, longitude, ctd pressure, and depth from the actual cast (e.g., TM or R) that the samples (DNA_ID) was collected from and associated metadata obtained from the regular CTD cast that was available from the same station or for Station 199, the closest station was 198.
