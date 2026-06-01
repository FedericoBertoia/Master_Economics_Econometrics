clear all

global mainDIR "C:\Users\feder\Desktop\Project\Bertoia (Causal Inference)\Replication Study Federico\Replication"
global dataDIR "C:\Users\feder\Desktop\Project\Bertoia (Causal Inference)\Replication Study Federico\Replication\data"
global outputDIR "C:\Users\feder\Desktop\Project\Bertoia (Causal Inference)\Replication Study Federico\Replication\output"


set more off
cd "$mainDIR"

/*
ssc install synth
ssc install distinct
ssc install elasticregress
*/


cap log close 
log using 1.Replicate_Figures.log, replace     

		
*==========================================
* Figure 1 (a): Panel A. Tax components
*==========================================
use data\descriptive_data, clear
tsset year


twoway line Real_Gasoline_Price year, ///
    lcolor(black) lwidth(medium) ytitle("Real price (SEK/litre)", margin(medium)) /// 
    xtitle("") yscale(range(0 12)) xline(1990, lpattern(dash)) title("Panel A. Tax components", position(11)) name(Figure1a) ylabel(#6) ///   
    legend(pos(11) ring(0) size(*0.8) col(1) order(1 "Gasoline price" 2 "Energy tax" 3 "VAT" 4 "Carbon tax") ///
    lpattern(solid solid dash_dot dash) lcolor(black gs7 black black) lwidth(medium)) ///
    ||line Real_Energytax year, lcolor(gs7) lpattern(solid) lwidth(medium) || ///
    line Real_VAT year, lcolor(black) lpattern(dash_dot) lwidth(medium) || ///
	line Real_Carbontax year, lcolor(black) lpattern(dash) lwidth(medium) 

	
	graph export output\Figure1a.png, replace
	
	
	
*======================================
* Figure 1 (b): Panel B. Total tax
*======================================

twoway line Real_Gasoline_Price year, ///
    lcolor(black) lwidth(medium) ytitle("Real price (SEK/litre)", margin(medium)) title("Panel B. Total tax", position(11)) name(Figure1b) ylabel(#6) ///
    xtitle("") yscale(range(0 12)) xline(1990, lpattern(dash)) ///
    legend(pos(11) ring(0) size(*0.8) col(1) order(1 "Gasoline price" 2 "Total tax" ) ///
    lpattern(solid dash) lcolor(black black) lwidth(medium)) ///
    || line Real_total_tax year, lcolor(black) lpattern(dash) lwidth(medium)
	
	graph export output\Figure1b.png, replace
	


*==========================================================================
* Figure 2: Road Sector Fuel Consumption per Capita in Sweden 1960-2005
*==========================================================================

format gas_cons diesel_cons %8.0f



twoway line gas_cons year, ///
       lcolor(black) lwidth(medium) ///
	   ytitle("Road sector fuel consumption per capita (kg of oil equivalent)", size(2.8) margin(medium)) name(Figure2) ylabel(#6) ///
	   xtitle("") yscale(range(0 600)) xline(1990, lpattern(dash)) ///
	   legend(pos(11) ring(0) size(*0.8) col(1) order(1 "Gasoline" 2 "Diesel")) ///
	   lpattern (solid dash) lcolor (black black) lwidth(medium) ///
	   text(100 1982 "VAT + carbon tax →", size(medium)) ///
	   || line diesel_cons year, lcolor(black) lpattern(dash) lwidth(medium)
	   
	
	
graph export output\Figure2.png, replace
	

	
*=================================================================================================================
* Figure 3: Path Plot of per capita CO2 Emissions from Transport: Sweden vs. the OECD Average (14 donor countries)
*=================================================================================================================

format CO2_Sweden CO2_OECD %8.1f

twoway line CO2_Sweden year, ///
       lcolor(black) lwidth(medium) ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) name(Figure3) ylabel(#7) ///
	   xtitle("") yscale(range(0 3)) xline(1990, lpattern(dash)) ///
	   legend(pos(7) ring(0) size(*0.8) col(1) order(1 "Sweden" 2 "OECD sample")) ///
	   lpattern (solid dash) lcolor (black black) lwidth(medium) ///
	   text(1 1982 "VAT + carbon tax →", size(medium)) ///
	   || line CO2_OECD year, color(black) lpattern(dash) lwidth(medium)
	   
graph export output\Figure3.png, replace


/*
use data\carbontax_data, clear
tsset Countryno year

bysort year: egen OECD_CO2_transport_capita = mean(CO2_transport_capita) if Countryno != 13

bysort year: gen CO2_Sweden = CO2_transport_capita if Countryno==13

twoway line CO2_Sweden year, ///
       lcolor(black) lwidth(medium) ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) ylabel(#7) ///
	   xtitle("") yscale(range(0 3)) xline(1990, lpattern(dash)) ///
	   legend(pos(7) ring(0) size(*0.8) col(1) order(1 "Sweden" 2 "OECD sample")) ///
	   lpattern (solid dash) lcolor (black black) lwidth(medium) ///
	   text(1 1982 "VAT + carbon tax →", size(medium)) ///
	   || line OECD_CO2_transport_capita year, color(black) lpattern(dash) lwidth(medium)

*/


*=================================================================================================================
* Figure 4: Path Plot of Per Capita CO2 Emissions from Transport during 1960–2005: Sweden versus Synthetic Sweden
*=================================================================================================================

use data\fullsample_figures, clear

tsset Year

twoway line sweden Year, ///
       lcolor(black) lwidth(medium) ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) name(Figure4) ylabel(0 (0.5) 3, format(%9.1fc)) ///
	   xtitle("") xline(1990, lpattern(dash)) ///
	   legend(pos(7) ring(0) size(*0.8) col(1) order(1 "Sweden" 2 "Synthetic Sweden")) ///
	   lpattern(solid dash) lcolor(blak black) lwidth(medium) ///
	   text(1 1982 "VAT + carbon tax →", size(medium)) ///
	   || line synth_sweden_original_sample Year, color(black) lpattern(dash) lwidth(medium)
	   
	   
graph export output\Figure4.png, replace

/*
use data\carbontax_data, clear
tsset Countryno year

synth CO2_transport_capita GDP_per_capita vehicles_capita gas_cons_capita urban_pop ///
CO2_transport_capita(1989) CO2_transport_capita(1980) CO2_transport_capita(1970), ///
trunit(13) trperiod(1990) xperiod(1980(1)1989) nested unitnames(country) figure iterate(2000) keep(synth_results)  replace 

ereturn list

matrix list e(X_balance)
matrix list e(W_weights)
matrix list e(V_matrix)

use synth_results, clear

twoway line _Y_treated _time, ///
       lcolor(black) lwidth(medium) ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) name(Figure4) ylabel(0 (0.5) 3, format(%9.1fc)) ///
	   xtitle("") xline(1990, lpattern(dash)) ///
	   legend(pos(7) ring(0) size(*0.8) col(1) order(1 "Sweden" 2 "Synthetic Sweden")) ///
	   lpattern(solid dash) lcolor(blak black) lwidth(medium) ///
	   text(1 1982 "VAT + carbon tax →", size(medium)) ///
	   || line _Y_synthetic _time, color(black) lpattern(dash) lwidth(medium)

*/


*=============================================================================================
* Figure 5: Gap in Per Capita CO2 Emissions from Transport between Sweden and Synthetic Sweden
*=============================================================================================
	   
twoway line CO2_reductions_original_sample Year, ///
       lcolor(black) lwidth(0.5) ytitle("Gap in metric tons per capita (CO2 from transport)", margin(medium)) name(Figure5) ///
	   ylabel(-0.4 (0.2) 0.4, format(%9.1fc)) ///
	   xtitle("") xline(1990, lpattern(dash) lcolor(red)) ///
	   text(0.3 1982 "VAT + carbon tax →", size(medium)) ///
	   yline(0, lpattern(dash) lcolor(black))
	   

graph export output\Figure5.png, replace

/*
use data\carbontax_data, clear
tsset Countryno year

synth CO2_transport_capita GDP_per_capita vehicles_capita gas_cons_capita urban_pop ///
CO2_transport_capita(1989) CO2_transport_capita(1980) CO2_transport_capita(1970), ///
trunit(13) trperiod(1990) xperiod(1980(1)1989) nested unitnames(country) figure iterate(2000) keep(synth_results)  replace 

use synth_results, clear

gen gap = _Y_treated - _Y_synthetic

twoway line gap _time, ///
       lcolor(black) lwidth(0.5) ytitle("Gap in metric tons per capita (CO2 from transport)", margin(medium)) name(Figure5) ///
	   ylabel(-0.4 (0.2) 0.4, format(%9.1fc)) ///
	   xtitle("") xline(1990, lpattern(dash) lcolor(red)) ///
	   text(0.3 1982 "VAT + carbon tax →", size(medium)) ///
	   yline(0, lpattern(dash) lcolor(black))

*/

*================================
* Figure 6: Placebo In-Time Tests
*================================

use data\carbontax_data, clear
tsset Countryno year



*Baseline synth estimation and figure 4/5
synth CO2_transport_capita GDP_per_capita vehicles_capita gas_cons_capita urban_pop ///
CO2_transport_capita(1989) CO2_transport_capita(1980) CO2_transport_capita(1970), ///
trunit(13) trperiod(1990) xperiod(1980(1)1989) nested unitnames(country) figure iterate(2000) keep(synth_results) replace   /*  .034956 */   

*customV(0.219 0.078 0.01 0.213 0.183 0.284 0.013)      rmspe  .0349572 

/*
use synth_results, clear
gen gap = _Y_treated - _Y_synthetic

sum gap if _time >=1990    -.2867492 ATT


*/


/*Practitioners should note there are several methods of estimating these vi h weights, including minimizing the mean squared
prediction error (MSPE) over the entire pre-treatment period or the cross-validation approach adopted in Abadie, Diamond, and
Hainmueller (2015). */

ereturn list
matrix list e(X_balance)
matrix list e(W_weights)
matrix list e(V_matrix)



*Placebo test in time for 1980

synth CO2_transport_capita GDP_per_capita vehicles_capita gas_cons_capita urban_pop ///
CO2_transport_capita(1979) CO2_transport_capita(1970) CO2_transport_capita(1965), ///
trunit(13) trperiod(1980) xperiod(1970(1)1979) nested unitnames(country) figure resultsperiod(1960(1)1990) iterate(2000)

graph export output\Figure6a.png, replace

*Placebo test in time for 1970

synth CO2_transport_capita GDP_per_capita vehicles_capita gas_cons_capita urban_pop ///
CO2_transport_capita(1970) CO2_transport_capita(1969) CO2_transport_capita(1968) CO2_transport_capita(1967) CO2_transport_capita(1966) ///
CO2_transport_capita(1965) CO2_transport_capita(1964) CO2_transport_capita(1963) CO2_transport_capita(1962) ///
CO2_transport_capita(1961) CO2_transport_capita(1960), ///
trunit(13) trperiod(1970) counit(1 2 3 4 5 6 7 8 9 11 12 14 15) xperiod(1960(1)1969) nested unitnames(country) ///
figure resultsperiod(1960(1)1990) iterate(2000)

graph export output\Figure6b.png, replace



*==============================================================================================================
* Figure 7: Permutation Test: Per Capita CO2 Emissions Gap in Sweden and Placebo Gaps for the Control Countries
*==============================================================================================================
use data\carbontax_data, clear
tsset Countryno year



*Panel A

allsynth CO2_transport_capita GDP_per_capita vehicles_capita gas_cons_capita urban_pop ///
CO2_transport_capita(1989) CO2_transport_capita(1980) CO2_transport_capita(1970), ///
trunit(13) trperiod(1990) xperiod(1980(1)1989) nested unitnames(country) iterate(2000) ///
pvalues plac gapfigure(classic placebos, ///
xlabel(1960 (10) 2000) ytitle(Gap in metric tons per capita (CO2 from transport))) ///
keep(Permutaion_results) replace 

graph export output\Figure7a.png, replace

/* twoway_options customed with Stata Graph editor

legend(label(1 "Sweden" 2 "Control countries"))	text(-0.45 1980 "VAT + carbon tax →") 

*/


/*
Panel A (synth_runner)
synth_runner CO2_transport_capita GDP_per_capita vehicles_capita gas_cons_capita urban_pop ///
CO2_transport_capita(1989) CO2_transport_capita(1980) CO2_transport_capita(1970), ///
trunit(13) trperiod(1990) gen_vars nested unitnames(country) xperiod(1980(1)1989) iterate(2000) 

sum post_rmspe if Countryno==13
tab country if post_rmspe> .3005885     p-val: 3/13 0.23

dis e(pval_joint_post) 
proportion of placebos that have a posttreatment RMSPE at
least as large as the average for the treated units



dis e(pval_joint_post_std) 
proportion of placebos that have a ratio of posttreatment RMSPE
over pretreatment RMSPE at least as large as the average
ratio for the treated units


If truly random, can modify the p-value
display (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)

ereturn list


single_treatment_graphs, ///
effects_ylabels(-1(0.5)1) effects_ytitle("Gap in metric tons per capita(CO2 from transport)")  


*Cannot calculate the placebo synthetic control for united states (nested problem)


*/



*Panel B

use data\carbontax_data, clear
gen id = _n
preserve
keep id country
save "country_dataset.dta", replace
restore
clear
use Permutaion_results, clear
sort Countryno _time
gen id = _n 
merge 1:1 id using "country_dataset.dta"


bysort Countryno: egen pre_mspe = mean(gap^2) if _time < 1990
bysort Countryno: egen ratio_mspe2 = mean(pre_mspe)

sum ratio_mspe2 if Countryno==13

tab country if ratio_mspe2>= 20*.0012254 /* 3 7 10 11 15 */


use data\carbontax_data, clear
tsset Countryno year


allsynth CO2_transport_capita GDP_per_capita vehicles_capita gas_cons_capita urban_pop ///
CO2_transport_capita(1989) CO2_transport_capita(1980) CO2_transport_capita(1970), ///
trunit(13) trperiod(1990) xperiod(1980(1)1989) nested unitnames(country) iterate(2000) ///
pvalues plac gapfigure(classic placebos, ///
xlabel(1960 (10) 2000) ytitle(Gap in metric tons per capita (CO2 from transport))) ///
keep(Permutaion_results_panelB) replace

graph export output\Figure7b.png, replace


/* twoway_options customed with Stata Graph editor

legend(label(1 "Sweden" 2 "Control countries"))	text(-0.45 1980 "VAT + carbon tax →") 
remove countries 3 7 10 11 15

*/



*==============================================================================================================
* Figure 8: Ratio Test: Ratios of Posttreatment MSPE to Pretreatment MSPE: Sweden and 14 OECD Control Countries
*==============================================================================================================
use data\carbontax_data, clear
gen id = _n
preserve
keep id country
save "country_dataset.dta", replace
restore
clear
use Permutaion_results, clear
sort Countryno _time
gen id = _n 
merge 1:1 id using "country_dataset.dta"



bysort Countryno: egen pre_mspe = mean(gap^2) if _time < 1990
bysort Countryno: egen post_mspe = mean(gap^2) if _time >= 1990

bysort Countryno: egen ratio_mspe1 = mean(post_mspe)
bysort Countryno: egen ratio_mspe2 = mean(pre_mspe)

bysort Countryno: gen ratio_mspe = ratio_mspe1/ratio_mspe2


tabstat ratio_mspe, by(country)


graph bar ratio_mspe , horizontal over(country, sort(ratio_mspe) descending) ///
ylabel(0 (10) 80) ytitle("Post-period MSPE/Pre-period MSPE", margin(medsmall)) name(Figure8)

graph export output\Figure8.png, replace




*==========================================================================
* Figure 9: Leave-One-Out: Distribution of the Synthetic Control for Sweden
*==========================================================================
use data\leave_one_out_data, clear
tsset Year
	   
	   
twoway line excl_belgium Year, color(gs14) lpattern(solid) lwidth(medium) ///
	   || line excl_denmark Year, color(gs14) lpattern(solid) lwidth(medium) || ///
	   || line excl_greece Year, color(gs14) lpattern(solid) lwidth(medium) || ///
	   || line excl_newzealand Year, color(gs14) lpattern(solid) lwidth(medium) || ///
	   || line excl_switzerland Year, color(gs14) lpattern(solid) lwidth(medium) || ///
	   || line excl_unitedstates Year, color(gs14) lpattern(solid) lwidth(medium)|| ///
	   || line synth_sweden Year, color(black) lpattern(dash) lwidth(medium) || ///
	   || line sweden Year, ///
       lcolor(black) lwidth(medium) ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) name(Figure9) ylabel(0 (0.5) 3, format(%9.1fc)) ///
	   xtitle("") xline(1990, lpattern(dash)) ///
	   legend(pos(7) ring(0) size(*0.8) col(1) order( 8 "Sweden"  7 "Synthetic Sweden"  1 "Synthetic Sweden (leave-one-out)") ///
	   lpattern(solid dash solid) lcolor(gs14 black black) lwidth(medium)) ///
	   text(1 1982 "VAT + carbon tax →", size(medium)) 
	   
	   graph export output\Figure9.png, replace
	   
	  
 
	   


*=========================================================================================================
* Figure 10: Path and Gap Plot of Per Capita CO2 Emissions from Transport: Main Results versus Full Sample 
*=========================================================================================================
use data\fullsample_figures, clear	
tsset Year

* Panel A

twoway line synth_sweden_full_sample Year, color(gs14) lpattern(solid) lwidth(medium)|| ///
	   || line synth_sweden_original_sample Year, color(black) lpattern(dash) lwidth(medium) || ///
	   || line sweden Year, ///
       lcolor(black) lwidth(medium) title("Panel A", position(11)) ///
	   ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) name(Figure10a) ylabel(0 (0.5) 3, format(%9.1fc)) ///
	   xtitle("") xline(1990, lpattern(dash)) ///
	   legend(pos(7) ring(0) size(*0.8) col(1) order( 3 "Sweden"  2 "Synthetic Sweden"  1 "Synthetic Sweden (full sample)") ///
	   lpattern(solid dash solid) lcolor(gs14 black black) lwidth(medium)) ///
	   text(1 1981 "VAT + carbon tax →", size(medium))
	   
	   graph export output\Figure10a.png, replace
	   
* Panel B
	   
twoway line CO2_reductions_full_sample Year, ///
       lcolor(gs14) lwidth(medium) title("Panel B", position(11)) ///
	   ytitle("Gap in metric tons per capita (CO2 from transport)", margin(medium)) name(Figure10b) ylabel(-0.4 (0.2) 0.4, format(%9.1fc)) ///
	   xtitle("") xline(1990, lpattern(dash)) ///
	   legend(pos(7) ring(0) size(*0.8) col(1) order( 2 "Main result (14 control countries)"  1 "Full sample (24 control countries)") ///
	   lpattern(solid solid) lcolor(black gs14) lwidth(medium)) ///
	   text(0.3 1981 "VAT + carbon tax →", size(medium)) ///
	   || line CO2_reductions_original_sample Year, ///
	   lcolor(black) lwidth(medium) lpattern(solid)
	   
	   graph export output\Figure10b.png, replace
	   
	   



*=======================================================
* Figure 11: GDP per capita: Sweden vs. Synthetic Sweden
*=======================================================
use data\descriptive_data, clear
tsset year

gen upper = 35000
gen lower = 0

twoway rarea lower upper year if year>=1991&year<=1993 , color(gs15)|| ///
       || rarea lower upper year if year>=1976&year<=1978 , color(gs15)|| ///
       || line GDP_Sweden year, ///
       lcolor(black) lwidth(medium) ytitle("GDP per capita (PPP, 2005 USD)", margin(medium)) name(Figure11) ylabel(#7) ///
	   xtitle("") yscale(range(0 35000)) xline(1990, lpattern(dash)) ///
	   legend(pos(7) ring(0) size(*0.8) col(1) order(3 "Sweden" 4 "Synthetic Sweden")) ///
	   lpattern (solid dash) lcolor (black black) lwidth(medium) ///
	   text(8000 1982 "VAT + carbon tax →", size(medium)) ///
	   || line GDP_Synthetic_Sweden year, color(black) lpattern(dash) lwidth(medium) 
	
	   

graph export output\Figure11.png, replace
	   
	
drop lower 
drop upper
	

*=================================================================================================================
* Figure 12: Gap in GDP per capita and CO2 Emissions per capita from Transport between Sweden and Synthetic Sweden
*=================================================================================================================

gen lower = -0.4
gen upper = 0.4
	   
twoway rarea lower upper year if year>=1991&year<=1993 , color(gs15) yaxis(1) || ///
	   || rarea lower upper year if year>=1976&year<=1978 , color(gs15) yaxis(1) || ///
       || line gap_CO2_emissions_transp year, ///
       yaxis(1) lcolor(black) lwidth(medium) name(Figure12) ///
	   ytitle("Gap in metric tons per capita (CO2 from transport)", margin(medium)) ylabel(-0.4 (0.2) 0.4, axis(1)) ///
	   xtitle("") xline(1990, lpattern(dash)) ///
	   legend(pos(7) ring(0) size(*0.8) col(1) order(3 "CO2 emissions (left y-axis)" 4 "GDP per capita (right y-axis)")) ///
	   lpattern (solid solid) lcolor (black gs7) lwidth(medium) ///
	   text(0.3 1980 "VAT + carbon tax →", size(medium)) ///
	   || line gap_GDP year, yaxis(2) color(gs7) lwidth(medium) lpattern(solid) ylabel(-2000 (1000) 2000, axis(2) format(%9.0fc)) ///
	   ytitle("Gap in GDP per capita (PPP, 2005 USD)", axis(2) margin(medium)) 
	   
graph export output\Figure12.png, replace
	    
		
	
		
*================================================
* Figure 13: Disentangling the Carbon Tax and VAT
*================================================		
use data\disentangling_data, clear 

tsset year

twoway line CarbonTaxandVAT year if year>=1970, ///
       lcolor(black) lpattern(solid) lwidth(medium) ///
	   ytitle("Metric tons per capita (CO2 from transport)", margin(medium)) name(Figure13) ylabel(0 (0.5) 3.5) ///
	   xtitle("") xline(1990, lpattern(dash)) xlabel(1970 (5) 2005) ///
	   legend(pos(7) ring(0) size(*0.8) col(1) order(2 "No carbon tax, no VAT" 3 "No carbon tax, with VAT" 1 "Carbon tax and VAT")) ///
	   text(1 1982 "VAT + carbon tax →", size(medium)) ///
	   || line NoCarbonTaxNoVAT year if year>=1970, color(black) lpattern(dash) lwidth(medium) || ///
	   || line NoCarbonTaxWithVAT year if year>=1970, color(black) lpattern(dash_dot) lwidth(medium)
	   
	   
	   graph export output\Figure13.png, replace


*===============================================================================================
* Figure 14: Gap in Per Capita CO2 Emissions from Transport: Synthetic Control versus Simulation
*===============================================================================================
use data\disentangling_data, clear

gen lower = -0.8
gen upper = 0.4
	   
twoway rarea lower upper year if year>=2000 , color(gs13) || ///
       || line CO2_reductions_synth year, ///
       lcolor(black) lwidth(medium) name(Figure14) ///
	   ytitle("Gap in metric tons per capita (CO2 from transport)", margin(medium)) ylabel(-0.8 (0.2) 0.4) ///
	   xtitle("") xline(1990, lpattern(dash)) xlabel(1960 (10) 2000) ///
	   legend(pos(7) ring(0) size(*0.8) col(1) order(2 "Synthetic control result" 3 "Simulation result")) ///
	   lpattern (solid solid) lcolor (black gs7) lwidth(medium) ///
	   text(0.3 1980 "VAT + carbon tax →", size(medium)) ///
	   || line CO2_reductions_simulation year, color(gs7) lwidth(medium) lpattern(solid) 


graph export output\Figure14.png, replace
	   	   	   	 
log close



 