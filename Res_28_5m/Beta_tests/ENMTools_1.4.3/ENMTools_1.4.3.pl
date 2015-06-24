#! /usr/local/ActivePerl-5.14/bin/perl
no warnings;


   
#use strict;
use Tkx;
Tkx::wm_title(".", "ENMTools");
Tkx::option_add("*tearOff", 0);

my $os = Tkx::tk_windowingsystem();  

my @now_showing;  #Contains a list of all widgets in the current window.  Calling the destroyEverything function kills everything it finds in @now_showing.

my %options;
my $scripting = 0;
my $scripting_nreps = 0;
my $scripting_npoints = 0;
my $layers_type = "Layers directory";
my $layers_path = "Not set";
my $script_path = "Not set";
my $maxent_path = "Not set";
my $biasfile_path = "Not set";
my $maxent_beta = "1";
my $samplesfile = "Not set";
my $backgroundfile = "Not set";
my $memory = "-mx512m";
my $pictures = '';
my $responsecurves = '';
my $rocplots = '';
my $modselfile;
my $suitability_type = "logistic";
my $trimdupes_type = "exact";
my $projectiondir = "Not set";
my $jackboot = "jackknife";
my $rangebreak_breaktype = "line";
my $crossvalidation_breaktype = "line";
my $removedupes = "removeduplicates";
my @overlap_files;
my @range_overlap_files;
my @corr_files;
my @breadth_files;
my @standardize_files;
my @rastersample_files;
my @trimDupes_files;
my $trimdupes_gridfile;
my $formatted_overlapfiles; # This is to stuff the list into a Tcl format for displaying in listboxes
my $formatted_range_overlapfiles;
my $formatted_corrfiles;
my $formatted_identityfiles; 
my $formatted_backgroundfiles;
my $formatted_jackbootfiles;  
my $formatted_rangebreakfiles;
my $formatted_crossvalidationfiles;
my @identity_files;
my @jackboot_files;
my @cleanup_files;
my @batchproject_files;
my @rangebreak_files;
my @crossvalidation_files;
my @background_analyses;
my @signtest_files1;
my @signtest_files2;
my $configfile = "enmtools.config";
my $output_directory = "Directory not set";
my $options_show_maxent = "no";
my $options_maxent_version;
my $fileprefix;
my $jackboot_keepreps = 0; 
my $rangebreak_keepreps = 0;
my $crossvalidation_keepreps = 0;
my $rangebreak_ribbonwidth;
my $rastersample_functiontype = "linear";
my $rastersample_replace = "no";
my $identity_keepreps=0;
my $background_keepreps=0;
my $jackboot_runmaxent = 1;
my $identity_runmaxent = 1;
my $background_runmaxent = 1;
my $rangebreak_runmaxent = 1;
my $crossvalidation_runmaxent = 1;
my $identity_usebinary = 0;
my $background_usebinary = 0;
my $corr_make_residuals = 1;
my $jackboot_type;
my $jackprop_disabled = "";
my $jackreps_disabled = "";
my $large_overlap = 0;

getOptions();
my $mw = Tkx::widget->new(".");
$mw->g_wm_geometry("640x480");
my $m = $mw->new_menu;
$mw->configure(-menu => $m);
my $Metrics = $m->new_menu;
my $Tests = $m->new_menu;
my $Resampling = $m->new_menu;
my $Options = $m->new_menu;

my $logo = $mw->new_ttk__label(-text => "Welcome to ENMTools");
$logo->g_grid(-padx=>50, -pady=>100);
push(@now_showing, $logo);
if(-e "enmtools_glitter.gif"){
	Tkx::image_create_photo( "imgobj", -file => "enmtools_glitter.gif");
	$logo->configure(-image => "imgobj");
}

my $scriptfile = shift;
if(-e $scriptfile){
	$scripting = 1;
	runScript();
	die "Finished!\n";
}

$m->add_cascade(-menu => $Metrics, -label => "ENM measurements and tools");
$m->add_cascade(-menu => $Tests, -label => "Hypothesis testing");
$m->add_cascade(-menu => $Resampling, -label => "Resampling");
$m->add_cascade(-menu => $Options, -label => "Options");

$Metrics->add_command(-label => "Niche overlap (ASCII files)", -command => sub {raiseOverlapWindow()});
$Metrics->add_command(-label => "Niche overlap (List)", -command => sub {pairwiseOverlap()});
$Metrics->add_command(-label => "Niche breadth", -command => sub {raiseBreadthWindow()});
$Metrics->add_command(-label => "Range overlap (ASCII files)", -command => sub {raiseRangeOverlapWindow()});
$Metrics->add_command(-label => "Standardize rasters", -command => sub {raiseStandardizeWindow()});
$Metrics->add_command(-label => "Correlation", -command => sub {raiseCorrWindow()});
$Metrics->add_command(-label => "Model selection", -command => sub {modselExecute()});
$Metrics->add_command(-label => "Trim duplicate occurrences", -command => sub {raiseTrimDupesWindow()});

$Tests->add_command(-label=> "Identity test", -command => sub {raiseIdentityWindow()});
$Tests->add_command(-label=> "Background test", -command => sub {raiseBackgroundWindow()});
$Tests->add_command(-label=> "Rangebreak test (linear)", -command => sub {
	$rangebreak_breaktype = 'line';
	raiseRangebreakWindow()});
$Tests->add_command(-label=> "Rangebreak test (ribbon)", -command => sub {
	$rangebreak_breaktype = 'ribbon';
	raiseRangebreakWindow()});
$Tests->add_command(-label=> "Rangebreak test (blob)", -command => sub {
	$rangebreak_breaktype = 'blob';
	raiseRangebreakWindow()});

$Resampling->add_command(-label=> "Nonparametric bootstrap", -command => sub {
	$jackboot_type = 'Nonparametric bootstrap';
	raiseJackbootWindow()});
$Resampling->add_command(-label=> "Delete D jackknife", -command => sub {
	$jackboot_type = 'Delete d jackknife';
	raiseJackbootWindow()});
$Resampling->add_command(-label=> "Delete 1 jackknife", -command => sub {
	$jackboot_type = 'Delete one jackknife (deterministic)';
	raiseJackbootWindow()});
$Resampling->add_command(-label=> "Retain X jackknife", -command => sub {
	$jackboot_type = 'Retain X jackknife';
	raiseJackbootWindow()});
$Resampling->add_command(-label=> "Spatial cross-validation (linear)", -command => sub {
	$crossvalidation_breaktype = 'line';
	raiseCrossvalidationWindow()});
$Resampling->add_command(-label=> "Spatial cross-validation (blob)", -command => sub {
	$crossvalidation_breaktype = 'blob';
	raiseCrossvalidationWindow()});
$Resampling->add_command(-label=> "Resample from raster", -command => sub {raiseRastersampleWindow()});

$Options->add_command(-label=> "ENMTools options", -command => sub {raiseENMToolsOptionWindow()});
$Options->add_command(-label=> "Maxent options", -command => sub {raiseMaxentOptionWindow()});
$Options->add_command(-label=> "Run script file", -command => sub {runScript()});
$Options->add_command(-label=> "About ENMTools", -command => sub {raiseAboutWindow()});

sub raiseOverlapWindow{
	destroyEverything();
	my $description = $mw->new_ttk__label(-text => "Measure niche overlap between two or more ASCII raster files.");
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $overlap_list_label = $mw-> new_ttk__label(-text => "Files to be compared:  ");
	$overlap_list_label -> g_grid();
	my $overlap_list_addbutton = $mw -> new_ttk__button(-text=>"Add files",-width=>20, -command=>\&overlapAddFiles);
	$overlap_list_addbutton -> g_grid(-row=>2, -column=>0, -padx=>50);
	my $overlap_list_import = $mw-> new_ttk__button(-text=>"Import file list", -width=>20, -command=>\&overlapImportList);
	$overlap_list_import -> g_grid(-row=>3, -column=>0, -padx=>50);
	my $overlap_list_export = $mw-> new_ttk__button(-text=>"Save file list",-width=>20, -command=>\&overlapExportList);
	$overlap_list_export -> g_grid(-row=>4, -column=>0, -padx=>50);
	my $overlap_list_clear = $mw-> new_ttk__button(-text=>"Clear file list", -width=>20, -command=>\&overlapClearFiles);
	$overlap_list_clear -> g_grid(-row=>5, -column=>0, -padx=>50);
	my $overlap_files_frame = $mw-> new_ttk__frame();
	our $overlap_files_list = $overlap_files_frame -> new_tk__listbox(-listvariable=>\$formatted_overlapfiles, -width=>40, -height=>10);
	my $overlap_files_scrollbar = $overlap_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$overlap_files_list, 'yview']);
	$overlap_files_list -> configure(-yscrollcommand=>[$overlap_files_scrollbar, 'set']);
	$overlap_files_list -> g_grid(-row=>1, -column=>1);
	$overlap_files_frame -> g_grid(-row=>1, -column=>1, -rowspan=>5);
	$overlap_files_scrollbar -> g_grid(-row=>1, -column=>2, -sticky=>"ns");
	my $overlap_name_label = $mw -> new_ttk__label(-text=>"Name for this analysis:  ");
	$overlap_name_label -> g_grid(-row=>6, -column=>0, -pady=>10);
	our $overlap_name_textbox = $mw -> new_ttk__entry();
	$overlap_name_textbox -> g_grid(-row=>6, -column=>1, -pady=>10, -padx =>50);
	my $overlap_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&overlapManual);
	$overlap_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	
	@now_showing = ($description, $overlap_list_label, $overlap_list_addbutton, $overlap_list_import, $overlap_list_export, 
					$overlap_list_clear, $overlap_files_frame, $overlap_files_list, $overlap_files_scrollbar, $overlap_name_label,
					$overlap_name_textbox, $overlap_go_button);
	
}

sub raiseRangeOverlapWindow{
	destroyEverything();
	my $description = $mw->new_ttk__label(-text => "Measure range overlap between two or more ASCII raster files.");
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $range_overlap_list_label = $mw-> new_ttk__label(-text => "Files to be compared:  ");
	$range_overlap_list_label -> g_grid();
	my $range_overlap_list_addbutton = $mw -> new_ttk__button(-text=>"Add files",-width=>20, -command=>\&rangeOverlapAddFiles);
	$range_overlap_list_addbutton -> g_grid(-row=>2, -column=>0, -padx=>50);
	my $range_overlap_list_import = $mw-> new_ttk__button(-text=>"Import file list", -width=>20, -command=>\&rangeOverlapImportList);
	$range_overlap_list_import -> g_grid(-row=>3, -column=>0, -padx=>50);
	my $range_overlap_list_export = $mw-> new_ttk__button(-text=>"Save file list",-width=>20, -command=>\&rangeOverlapExportList);
	$range_overlap_list_export -> g_grid(-row=>4, -column=>0, -padx=>50);
	my $range_overlap_list_clear = $mw-> new_ttk__button(-text=>"Clear file list", -width=>20, -command=>\&rangeOverlapClearFiles);
	$range_overlap_list_clear -> g_grid(-row=>5, -column=>0, -padx=>50);
	my $range_overlap_files_frame = $mw-> new_ttk__frame();
	our $range_overlap_files_list = $range_overlap_files_frame -> new_tk__listbox(-listvariable=>\$formatted_range_overlapfiles, -width=>40, -height=>10);
	my $range_overlap_files_scrollbar = $range_overlap_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$range_overlap_files_list, 'yview']);
	$range_overlap_files_list -> configure(-yscrollcommand=>[$range_overlap_files_scrollbar, 'set']);
	$range_overlap_files_list -> g_grid(-row=>1, -column=>1);
	$range_overlap_files_frame -> g_grid(-row=>1, -column=>1, -rowspan=>5);
	$range_overlap_files_scrollbar -> g_grid(-row=>1, -column=>2, -sticky=>"ns");
	my $range_overlap_cutoff_label = $mw -> new_ttk__label(-text=>"Suitability threshold for presence:  ");
	$range_overlap_cutoff_label -> g_grid(-row=>6, -column=>0, -pady=>10);
	our $range_overlap_cutoff_textbox = $mw -> new_ttk__entry();
	$range_overlap_cutoff_textbox -> g_grid(-row=>6, -column=>1, -pady=>10, -padx =>50);
	my $range_overlap_name_label = $mw -> new_ttk__label(-text=>"Name for this analysis:  ");
	$range_overlap_name_label -> g_grid(-row=>7, -column=>0, -pady=>10);
	our $range_overlap_name_textbox = $mw -> new_ttk__entry();
	$range_overlap_name_textbox -> g_grid(-row=>7, -column=>1, -pady=>10, -padx =>50);
	my $range_overlap_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&rangeOverlapManual);
	$range_overlap_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	
	@now_showing = ($description, $range_overlap_list_label, $range_overlap_list_addbutton, $range_overlap_list_import, $range_overlap_list_export, 
					$range_overlap_list_clear, $range_overlap_files_frame, $range_overlap_files_list, $range_overlap_files_scrollbar, $range_overlap_name_label,
					$range_overlap_name_textbox, $range_overlap_go_button, $range_overlap_cutoff_label,$range_overlap_cutoff_textbox);
	
}

sub raiseBreadthWindow{
	destroyEverything();
	our $description = $mw->new_ttk__label(-text => "Measure niche breadth on ASCII raster files.");
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $breadth_list_label = $mw-> new_ttk__label(-text => "Files to measure:  ");
	$breadth_list_label -> g_grid();
	my $breadth_list_addbutton = $mw -> new_ttk__button(-text=>"Add files",-width=>20, -command=>\&breadthAddFiles);
	$breadth_list_addbutton -> g_grid(-row=>2, -column=>0, -padx=>50);
	my $breadth_list_import = $mw-> new_ttk__button(-text=>"Import file list", -width=>20, -command=>\&breadthImportList);
	$breadth_list_import -> g_grid(-row=>3, -column=>0, -padx=>50);
	my $breadth_list_export = $mw-> new_ttk__button(-text=>"Save file list",-width=>20, -command=>\&breadthExportList);
	$breadth_list_export -> g_grid(-row=>4, -column=>0, -padx=>50);
	my $breadth_list_clear = $mw-> new_ttk__button(-text=>"Clear file list", -width=>20, -command=>\&breadthClearFiles);
	$breadth_list_clear -> g_grid(-row=>5, -column=>0, -padx=>50);
	my $breadth_files_frame = $mw-> new_ttk__frame();
	our $breadth_files_list = $breadth_files_frame -> new_tk__listbox(-listvariable=>\$formatted_breadthfiles, -width=>40, -height=>10);
	my $breadth_files_scrollbar = $breadth_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$breadth_files_list, 'yview']);
	$breadth_files_list -> configure(-yscrollcommand=>[$breadth_files_scrollbar, 'set']);
	$breadth_files_list -> g_grid(-row=>1, -column=>1);
	$breadth_files_frame -> g_grid(-row=>1, -column=>1, -rowspan=>5);
	$breadth_files_scrollbar -> g_grid(-row=>1, -column=>2, -sticky=>"ns");
	my $breadth_name_label = $mw -> new_ttk__label(-text=>"Name for this analysis:  ");
	$breadth_name_label -> g_grid(-row=>6, -column=>0, -pady=>10);
	our $breadth_name_textbox = $mw -> new_ttk__entry();
	$breadth_name_textbox -> g_grid(-row=>6, -column=>1, -pady=>10, -padx =>50);
	my $breadth_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&breadthManual);
	$breadth_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	
	@now_showing = ($description, $breadth_list_label, $breadth_list_addbutton, $breadth_list_import, $breadth_list_export, 
					$breadth_list_clear, $breadth_files_frame, $breadth_files_list, $breadth_files_scrollbar, $breadth_name_label,
					$breadth_name_textbox, $breadth_go_button);
}


sub raiseStandardizeWindow{
	destroyEverything();
	our $description = $mw->new_ttk__label(-text => "Standardize ASCII raster files so that suitabilities sum to 1.");
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $standardize_list_label = $mw-> new_ttk__label(-text => "Files to standardize:  ");
	$standardize_list_label -> g_grid();
	my $standardize_list_addbutton = $mw -> new_ttk__button(-text=>"Add files",-width=>20, -command=>\&standardizeAddFiles);
	$standardize_list_addbutton -> g_grid(-row=>2, -column=>0, -padx=>50);
	my $standardize_list_import = $mw-> new_ttk__button(-text=>"Import file list", -width=>20, -command=>\&standardizeImportList);
	$standardize_list_import -> g_grid(-row=>3, -column=>0, -padx=>50);
	my $standardize_list_export = $mw-> new_ttk__button(-text=>"Save file list",-width=>20, -command=>\&standardizeExportList);
	$standardize_list_export -> g_grid(-row=>4, -column=>0, -padx=>50);
	my $standardize_list_clear = $mw-> new_ttk__button(-text=>"Clear file list", -width=>20, -command=>\&standardizeClearFiles);
	$standardize_list_clear -> g_grid(-row=>5, -column=>0, -padx=>50);
	my $standardize_files_frame = $mw-> new_ttk__frame();
	our $standardize_files_list = $standardize_files_frame -> new_tk__listbox(-listvariable=>\$formatted_standardizefiles, -width=>40, -height=>10);
	my $standardize_files_scrollbar = $standardize_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$standardize_files_list, 'yview']);
	$standardize_files_list -> configure(-yscrollcommand=>[$standardize_files_scrollbar, 'set']);
	$standardize_files_list -> g_grid(-row=>1, -column=>1);
	$standardize_files_frame -> g_grid(-row=>1, -column=>1, -rowspan=>5);
	$standardize_files_scrollbar -> g_grid(-row=>1, -column=>2, -sticky=>"ns");
	my $standardize_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&standardizeManual);
	$standardize_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	
	@now_showing = ($description, $standardize_list_label, $standardize_list_addbutton, $standardize_list_import, $standardize_list_export, 
					$standardize_list_clear, $standardize_files_frame, $standardize_files_list, $standardize_files_scrollbar, $standardize_go_button);
}

sub raiseCorrWindow{
	destroyEverything();
	my $description = $mw->new_ttk__label(-text => "Measure correlation between two or more ASCII raster files.");
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $corr_list_label = $mw-> new_ttk__label(-text => "Files to be compared:  ");
	$corr_list_label -> g_grid();
	my $corr_list_addbutton = $mw -> new_ttk__button(-text=>"Add files",-width=>20, -command=>\&corrAddFiles);
	$corr_list_addbutton -> g_grid(-row=>2, -column=>0, -padx=>50);
	my $corr_list_import = $mw-> new_ttk__button(-text=>"Import file list", -width=>20, -command=>\&corrImportList);
	$corr_list_import -> g_grid(-row=>3, -column=>0, -padx=>50);
	my $corr_list_export = $mw-> new_ttk__button(-text=>"Save file list",-width=>20, -command=>\&corrExportList);
	$corr_list_export -> g_grid(-row=>4, -column=>0, -padx=>50);
	my $corr_list_clear = $mw-> new_ttk__button(-text=>"Clear file list", -width=>20, -command=>\&corrClearFiles);
	$corr_list_clear -> g_grid(-row=>5, -column=>0, -padx=>50);
	my $corr_files_frame = $mw-> new_ttk__frame();
	our $corr_files_list = $corr_files_frame -> new_tk__listbox(-listvariable=>\$formatted_corrfiles, -width=>40, -height=>10);
	my $corr_files_scrollbar = $corr_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$corr_files_list, 'yview']);
	$corr_files_list -> configure(-yscrollcommand=>[$corr_files_scrollbar, 'set']);
	$corr_files_list -> g_grid(-row=>1, -column=>1);
	$corr_files_frame -> g_grid(-row=>1, -column=>1, -rowspan=>5);
	$corr_files_scrollbar -> g_grid(-row=>1, -column=>2, -sticky=>"ns");
	my $corr_name_label = $mw -> new_ttk__label(-text=>"Name for this analysis:  ");
	$corr_name_label -> g_grid(-row=>6, -column=>0, -pady=>10);
	our $corr_name_textbox = $mw -> new_ttk__entry();
	$corr_name_textbox -> g_grid(-row=>6, -column=>1, -pady=>10, -padx =>50);
	my $corr_make_residuals_chk = $mw -> new_ttk__checkbutton(-text=>"Make residual grids", -variable=>\$corr_make_residuals);
	$corr_make_residuals_chk -> g_grid (-row=>7, -column=>0, -columnspan=>5, -pady=>5);
	my $corr_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&corrManual);
	$corr_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	
	@now_showing = ($description, $corr_list_label, $corr_list_addbutton, $corr_list_import, $corr_list_export, 
					$corr_list_clear, $corr_files_frame, $corr_files_list, $corr_files_scrollbar, $corr_name_label,
					$corr_name_textbox, $corr_go_button, $corr_make_residuals_chk);
	
}

sub raiseTrimDupesWindow{
	destroyEverything();
	my $description = $mw->new_ttk__label(-text => "Trim duplicate occurrences from .csv files.");
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $trimdupes_list_label = $mw-> new_ttk__label(-text => "Files to be trimmed:  ");
	$trimdupes_list_label -> g_grid();
	my $trimdupes_list_addbutton = $mw -> new_ttk__button(-text=>"Add files",-width=>20, -command=>\&trimdupesAddFiles);
	$trimdupes_list_addbutton -> g_grid(-row=>2, -column=>0, -padx=>50);
	my $trimdupes_list_import = $mw-> new_ttk__button(-text=>"Import file list", -width=>20, -command=>\&trimdupesImportList);
	$trimdupes_list_import -> g_grid(-row=>3, -column=>0, -padx=>50);
	my $trimdupes_list_export = $mw-> new_ttk__button(-text=>"Save file list",-width=>20, -command=>\&trimdupesExportList);
	$trimdupes_list_export -> g_grid(-row=>4, -column=>0, -padx=>50);
	my $trimdupes_list_clear = $mw-> new_ttk__button(-text=>"Clear file list", -width=>20, -command=>\&trimdupesClearFiles);
	$trimdupes_list_clear -> g_grid(-row=>5, -column=>0, -padx=>50);
	my $trimdupes_files_frame = $mw-> new_ttk__frame();
	our $trimdupes_files_list = $trimdupes_files_frame -> new_tk__listbox(-listvariable=>\$formatted_trimdupesfiles, -width=>40, -height=>10);
	my $trimdupes_files_scrollbar = $trimdupes_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$trimdupes_files_list, 'yview']);
	$trimdupes_files_list -> configure(-yscrollcommand=>[$trimdupes_files_scrollbar, 'set']);
	$trimdupes_files_list -> g_grid(-row=>1, -column=>1);
	$trimdupes_files_frame -> g_grid(-row=>1, -column=>1, -rowspan=>5);
	$trimdupes_files_scrollbar -> g_grid(-row=>1, -column=>2, -sticky=>"ns");
	
  my $trimdupes_type_frame = $mw-> new_ttk__frame();
	my $trimdupes_type_label = $mw -> new_ttk__label(-text=>"Method: ");
	my $trimdupes_exact_rdb = $trimdupes_type_frame -> new_ttk__radiobutton(-text=>"Exact match",  
			-value=>"exact",  -variable=>\$trimdupes_type);
	my $trimdupes_grid_rdb = $trimdupes_type_frame -> new_ttk__radiobutton(-text=>"Grid cell",
			-value=>"grid",-variable=>\$trimdupes_type);
	$trimdupes_type_label -> g_grid(-sticky=>"nwes", -row=>7, -column=>0, -pady=>5, -padx=>100);
	$trimdupes_exact_rdb -> g_grid(-row=>1, -column=>0,-padx=>5);
	$trimdupes_grid_rdb -> g_grid(-row=>1, -column=>1,-padx=>5);
	$trimdupes_type_frame -> g_grid (-sticky=>"nwes", -row=>7, -column=>1, -columnspan=>1, -padx=>20);
		
	
	my $trimdupes_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&trimdupesManual);
	$trimdupes_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	
	@now_showing = ($description, $trimdupes_list_label, $trimdupes_list_addbutton, $trimdupes_list_import, $trimdupes_list_export, 
					$trimdupes_list_clear, $trimdupes_files_frame, $trimdupes_files_list, $trimdupes_files_scrollbar, $trimdupes_go_button, 
					$trimdupes_type_label, 	$trimdupes_exact_rdb, $trimdupes_grid_rdb,	$trimdupes_type_frame	);
}


sub raiseStatsWindow{
	destroyEverything();
	our $description = $mw->new_ttk__label(-text => "Summary statistics for ASCII raster files.");
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	@now_showing = ($description);
}

sub raiseIdentityWindow{
	destroyEverything();
	our $description = $mw->new_ttk__label(-text => "Test the hypothesis that two populations were drawn from an\nidentical distribution of environmental variables.");
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $identity_list_label = $mw-> new_ttk__label(-text => "Occurrence files:  ");
	$identity_list_label -> g_grid();
	my $identity_list_addbutton = $mw -> new_ttk__button(-text=>"Add files",-width=>20, -command=>\&identityAddFiles);
	$identity_list_addbutton -> g_grid(-row=>2, -column=>0, -padx=>50);
	my $identity_list_import = $mw-> new_ttk__button(-text=>"Import file list", -width=>20, -command=>\&identityImportList);
	$identity_list_import -> g_grid(-row=>3, -column=>0, -padx=>50);
	my $identity_list_export = $mw-> new_ttk__button(-text=>"Save file list",-width=>20, -command=>\&identityExportList);
	$identity_list_export -> g_grid(-row=>4, -column=>0, -padx=>50);
	my $identity_list_clear = $mw-> new_ttk__button(-text=>"Clear file list", -width=>20, -command=>\&identityClearFiles);
	$identity_list_clear -> g_grid(-row=>5, -column=>0, -padx=>50);
	my $identity_files_frame = $mw-> new_ttk__frame();
	our $identity_files_list = $identity_files_frame -> new_tk__listbox(-listvariable=>\$formatted_identityfiles, -width=>40, -height=>10);
	my $identity_files_scrollbar = $identity_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$identity_files_list, 'yview']);
	$identity_files_list -> configure(-yscrollcommand=>[$identity_files_scrollbar, 'set']);
	$identity_files_list -> g_grid(-row=>1, -column=>1);
	$identity_files_frame -> g_grid(-row=>1, -column=>1, -rowspan=>5);
	$identity_files_scrollbar -> g_grid(-row=>1, -column=>2, -sticky=>"ns");
	my $identity_nreps_label = $mw -> new_ttk__label(-text=>"Number of replicates:  ");
	$identity_nreps_label -> g_grid(-row=>6, -column=>0, -pady=>10);
	our $identity_nreps_textbox = $mw -> new_ttk__entry();
	$identity_nreps_textbox -> g_grid(-row=>6, -column=>1, -pady=>10, -padx =>50);
	
	my $identity_runmaxent_chk = $mw -> new_ttk__checkbutton(-text=>"Run Maxent", -variable=>\$identity_runmaxent);
	$identity_runmaxent_chk -> g_grid (-row=>9, -column=>0, -columnspan=>5, -pady=>5);
	my $identity_keepreps_chk = $mw -> new_ttk__checkbutton(-text=>"Keep pseudoreplicate files", -variable=>\$identity_keepreps);
	$identity_keepreps_chk -> g_grid (-row=>10, -column=>0, -columnspan=>5, -pady=>5);
	my $identity_usebinary_chk = $mw -> new_ttk__checkbutton(-text=>"Binary predictions using minimum training presence", -variable=>\$identity_usebinary);
	$identity_usebinary_chk -> g_grid (-row=>11, -column=>0, -columnspan=>5, -pady=>5);
		
	
	
	my $identity_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&identityExecute);
	$identity_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	
	@now_showing = ($description, $identity_list_label, $identity_list_addbutton, $identity_list_import, $identity_list_export, 
					$identity_list_clear, $identity_files_frame, $identity_files_list, $identity_files_scrollbar, $identity_nreps_label,
					$identity_nreps_textbox, $identity_go_button, $identity_runmaxent_chk, $identity_keepreps_chk, $identity_usebinary_chk);
}

sub raiseBackgroundWindow{
	destroyEverything();
	our $description = $mw->new_ttk__label(-text => "Test the hypothesis that two species are more or less similar than expected based\non some estimate of the environmental background from which they are drawn.");
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	
	my $background_list_label = $mw -> new_ttk__label(-text => "Scheduled analyses:  ");
	$background_list_label -> g_grid(-row=>7, -column=>0);
	my $background_list_addsamplesbutton = $mw -> new_ttk__button(-text=>"Focal species occurrences",-width=>20, -command=>\&backgroundAddSamples);
	$background_list_addsamplesbutton -> g_grid(-row=>1, -column=>0, -padx=>2, -pady=>5);
	my $background_samples_text = $mw -> new_ttk__label(-textvariable=>\$samplesfile);
	$background_samples_text -> g_grid(-row=>1, -column=>1, -padx=>5);
	my $background_list_addbackgroundbutton = $mw -> new_ttk__button(-text=>"Background samples", -width=>20, -command=>\&backgroundAddBackground);
	$background_list_addbackgroundbutton -> g_grid(-row=>2, -column=>0, -padx=>2, -pady=>5);
	my $background_background_text = $mw -> new_ttk__label(-textvariable=>\$backgroundfile);
	$background_background_text -> g_grid(-row=>2, -column=>1, -padx=>5);
	my $background_list_addanalysisbutton = $mw -> new_ttk__button(-text=>"Add this analysis",-width=>20, -command=>\&backgroundAddAnalysis);
	$background_list_addanalysisbutton -> g_grid(-row=>8, -column=>0, -columnspan=>1, -padx=>2, -pady=>5);
	my $background_list_clear = $mw -> new_ttk__button(-text=>"Clear list", -width=>20, -command=>\&backgroundClearFiles);
	$background_list_clear -> g_grid(-row=>9, -column=>0, -columnspan=>1, -padx=>2, -pady=>5);
	my $background_files_frame = $mw -> new_ttk__frame();
	my $background_files_list = $background_files_frame -> new_tk__listbox(-listvariable=>\$formatted_backgroundfiles, -width=>50, -height=>5);
	my $background_files_yscrollbar = $background_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$background_files_list, 'yview']);
	my $background_files_xscrollbar = $background_files_frame -> new_ttk__scrollbar(-orient=>'horizontal',-command=>[$background_files_list, 'xview']);
	$background_files_list -> configure(-yscrollcommand=>[$background_files_yscrollbar, 'set'], -xscrollcommand=>[$background_files_xscrollbar, 'set']);
	$background_files_list -> g_grid(-row=>1, -column=>0);
	$background_files_frame -> g_grid(-row=>7, -column=>1, -rowspan=>3, -columnspan=>4);
	$background_files_yscrollbar -> g_grid(-row=>1, -column=>1, -sticky=>"ns");
	$background_files_xscrollbar -> g_grid(-row=>3, -column=>0, -sticky=>"ew");
	
	my $background_nreps_label = $mw -> new_ttk__label(-text=>"Number of replicates:  ");
	$background_nreps_label -> g_grid(-row=>3, -column=>0, -pady=>5);
	our $background_nreps_textbox = $mw -> new_ttk__entry();
	$background_nreps_textbox -> g_grid(-row=>3, -column=>1, -pady=>5, -padx =>50);
	
	my $background_nsamples_label = $mw -> new_ttk__label(-text=>"Number of background samples:  ");
	$background_nsamples_label -> g_grid(-row=>4, -column=>0, -pady=>5);
	our $background_nsamples_textbox = $mw -> new_ttk__entry();
	$background_nsamples_textbox -> g_grid(-row=>4, -column=>1, -pady=>5, -padx =>50);
	
	my $background_runmaxent_chk = $mw -> new_ttk__checkbutton(-text=>"Run Maxent", -variable=>\$background_runmaxent);
	$background_runmaxent_chk -> g_grid (-row=>15, -column=>0, -columnspan=>5, -pady=>5);
	my $background_keepreps_chk = $mw -> new_ttk__checkbutton(-text=>"Keep pseudoreplicate files", -variable=>\$background_keepreps);
	$background_keepreps_chk -> g_grid (-row=>16, -column=>0, -columnspan=>5, -pady=>5);
	my $background_usebinary_chk = $mw -> new_ttk__checkbutton(-text=>"Binary predictions using minimum training presence", -variable=>\$background_usebinary);
	$background_usebinary_chk -> g_grid (-row=>17, -column=>0, -columnspan=>5, -pady=>5);
	my $background_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&backgroundExecute);
	$background_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	@now_showing = ($description, $background_list_label, $background_list_addanalysisbutton, $background_list_clear, $background_list_addsamplesbutton, 
	$background_list_addbackgroundbutton, $background_background_text, $background_samples_text, $background_nreps_label, $background_nreps_textbox, 
	$background_nsamples_label, $background_nsamples_textbox, $background_files_frame, $background_go_button, $background_runmaxent_chk, $background_keepreps_chk, 
	$background_usebinary_chk);
}

sub raiseRangebreakWindow{
	destroyEverything();
	my $description;
	my $rangebreak_ribbonwidth_label;
	our $rangebreak_ribbonwidth_textbox;
	my $rangebreak_nreps_label = $mw -> new_ttk__label(-text=>"Number of replicates:  ");
	$rangebreak_nreps_label -> g_grid(-row=>6, -column=>0, -pady=>10);
	our $rangebreak_nreps_textbox = $mw -> new_ttk__entry();
	$rangebreak_nreps_textbox -> g_grid(-row=>6, -column=>1, -pady=>10, -padx =>50);
	push(@now_showing, ($rangebreak_nreps_label, $rangebreak_nreps_textbox)); 
	if($rangebreak_breaktype eq "line"){
		$description = $mw->new_ttk__label(-text => "Randomly partition the pooled range of two species along a straight line");
	}
	if($rangebreak_breaktype eq "ribbon"){
		$description = $mw->new_ttk__label(-text => "Randomly partition the pooled range of two species using a linear barrier of a specified width.");
		$rangebreak_ribbonwidth_label = $mw -> new_ttk__label(-text=>"Width of barrier:  ");
		$rangebreak_ribbonwidth_label -> g_grid(-row=>7, -column=>0, -pady=>10);
		$rangebreak_ribbonwidth_textbox = $mw -> new_ttk__entry();
		$rangebreak_ribbonwidth_textbox -> g_grid(-row=>7, -column=>1, -pady=>10, -padx =>50);
		push(@now_showing, ($rangebreak_nreps_label, $rangebreak_nreps_textbox, $rangebreak_ribbonwidth_label, $rangebreak_ribbonwidth_textbox)); 
	}
	if($rangebreak_breaktype eq "blob"){
		$description = $mw->new_ttk__label(-text => "Partition the pooled range of two species using a polygon\ncentered around a randomly chosen occurrence point.");
	}
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $rangebreak_list_label = $mw-> new_ttk__label(-text => "Files containing occurrences:  ");
	$rangebreak_list_label -> g_grid(-row=>1, -column=>0);
	my $rangebreak_list_addbutton = $mw -> new_ttk__button(-text=>"Add files",-width=>20, -command=>\&rangebreakAddFiles);
	$rangebreak_list_addbutton -> g_grid(-row=>2, -column=>0, -padx=>50);
	my $rangebreak_list_import = $mw-> new_ttk__button(-text=>"Import file list", -width=>20, -command=>\&rangebreakImportList);
	$rangebreak_list_import -> g_grid(-row=>3, -column=>0, -padx=>50);
	my $rangebreak_list_export = $mw-> new_ttk__button(-text=>"Save file list",-width=>20, -command=>\&rangebreakExportList);
	$rangebreak_list_export -> g_grid(-row=>4, -column=>0, -padx=>50);
	my $rangebreak_list_clear = $mw-> new_ttk__button(-text=>"Clear file list", -width=>20, -command=>\&rangebreakClearFiles);
	$rangebreak_list_clear -> g_grid(-row=>5, -column=>0, -padx=>50);
	my $rangebreak_files_frame = $mw-> new_ttk__frame();
	our $rangebreak_files_list = $rangebreak_files_frame -> new_tk__listbox(-listvariable=>\$formatted_rangebreakfiles, -width=>40, -height=>10);
	my $rangebreak_files_scrollbar = $rangebreak_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$rangebreak_files_list, 'yview']);
	$rangebreak_files_list -> configure(-yscrollcommand=>[$rangebreak_files_scrollbar, 'set']);
	$rangebreak_files_list -> g_grid(-row=>1, -column=>1);
	$rangebreak_files_frame -> g_grid(-row=>1, -column=>1, -rowspan=>5);
	$rangebreak_files_scrollbar -> g_grid(-row=>1, -column=>2, -sticky=>"ns");
	
	my $rangebreak_runmaxent_chk = $mw -> new_ttk__checkbutton(-text=>"Run Maxent", -variable=>\$rangebreak_runmaxent);
	$rangebreak_runmaxent_chk -> g_grid (-row=>9, -column=>1, -columnspan=>5, -pady=>5);

	my $rangebreak_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&rangebreakExecute);
	$rangebreak_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	
	push(@now_showing, ($description, $rangebreak_list_label, $rangebreak_list_addbutton, $rangebreak_list_import, $rangebreak_list_export, 
					$rangebreak_list_clear, $rangebreak_files_frame, $rangebreak_files_list, $rangebreak_files_scrollbar, $rangebreak_runmaxent_chk, $rangebreak_go_button)); 
					#Have to do push on this one because some widgets may not be defined
}

sub raiseJackbootWindow{
	destroyEverything();
	#'Delete one jackknife (deterministic)', 'Delete d jackknife', 'Retain X jackknife', 'Nonparametric bootstrap'
	my $description;
	my $jackboot_nreps_label;
	our $jackboot_nreps_textbox;
	my $jackboot_d_label;
	our $jackboot_d_textbox;
	if($jackboot_type eq "Delete one jackknife (deterministic)"){
		$description = $mw->new_ttk__label(-text => "Delete one jackknife (deterministic)");
	}
	if($jackboot_type eq "Delete d jackknife"){
		$description = $mw->new_ttk__label(-text => "Delete d jackknife");
		$jackboot_nreps_label = $mw -> new_ttk__label(-text=>"Number of replicates:  ");
		$jackboot_nreps_label -> g_grid(-row=>6, -column=>0, -pady=>10);
		$jackboot_nreps_textbox = $mw -> new_ttk__entry();
		$jackboot_nreps_textbox -> g_grid(-row=>6, -column=>1, -pady=>10, -padx =>50);
		$jackboot_d_label = $mw -> new_ttk__label(-text=>"Proportion of records to delete (d/n):  ");
		$jackboot_d_label -> g_grid(-row=>7, -column=>0, -pady=>10);
		$jackboot_d_textbox = $mw -> new_ttk__entry();
		$jackboot_d_textbox -> g_grid(-row=>7, -column=>1, -pady=>10, -padx =>50);
		push(@now_showing, ($jackboot_nreps_label, $jackboot_nreps_textbox, $jackboot_d_label, $jackboot_d_textbox)); 
	}
	if($jackboot_type eq "Retain X jackknife"){
		$description = $mw->new_ttk__label(-text => "Retain X jackknife");
		$jackboot_nreps_label = $mw -> new_ttk__label(-text=>"Number of replicates:  ");
		$jackboot_nreps_label -> g_grid(-row=>6, -column=>0, -pady=>10);
		$jackboot_nreps_textbox = $mw -> new_ttk__entry();
		$jackboot_nreps_textbox -> g_grid(-row=>6, -column=>1, -pady=>10, -padx =>50);
		$jackboot_d_label = $mw -> new_ttk__label(-text=>"Number of records to retain each rep:  ");
		$jackboot_d_label -> g_grid(-row=>7, -column=>0, -pady=>10);
		$jackboot_d_textbox = $mw -> new_ttk__entry();
		$jackboot_d_textbox -> g_grid(-row=>7, -column=>1, -pady=>10, -padx =>50);
		push(@now_showing, ($jackboot_nreps_label, $jackboot_nreps_textbox, $jackboot_d_label, $jackboot_d_textbox)); 
	}
	if($jackboot_type eq "Nonparametric bootstrap"){
		$description = $mw->new_ttk__label(-text => "Nonparametric bootstrap");
		$jackboot_nreps_label = $mw -> new_ttk__label(-text=>"Number of replicates:  ");
		$jackboot_nreps_label -> g_grid(-row=>6, -column=>0, -pady=>10);
		$jackboot_nreps_textbox = $mw -> new_ttk__entry();
		$jackboot_nreps_textbox -> g_grid(-row=>6, -column=>1, -pady=>10, -padx =>50);
		push(@now_showing, ($jackboot_nreps_label, $jackboot_nreps_textbox));
	}
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $jackboot_list_label = $mw-> new_ttk__label(-text => "Files containing occurrences:  ");
	$jackboot_list_label -> g_grid(-row=>1, -column=>0);
	my $jackboot_list_addbutton = $mw -> new_ttk__button(-text=>"Add files",-width=>20, -command=>\&jackbootAddFiles);
	$jackboot_list_addbutton -> g_grid(-row=>2, -column=>0, -padx=>50);
	my $jackboot_list_import = $mw-> new_ttk__button(-text=>"Import file list", -width=>20, -command=>\&jackbootImportList);
	$jackboot_list_import -> g_grid(-row=>3, -column=>0, -padx=>50);
	my $jackboot_list_export = $mw-> new_ttk__button(-text=>"Save file list",-width=>20, -command=>\&jackbootExportList);
	$jackboot_list_export -> g_grid(-row=>4, -column=>0, -padx=>50);
	my $jackboot_list_clear = $mw-> new_ttk__button(-text=>"Clear file list", -width=>20, -command=>\&jackbootClearFiles);
	$jackboot_list_clear -> g_grid(-row=>5, -column=>0, -padx=>50);
	my $jackboot_files_frame = $mw-> new_ttk__frame();
	our $jackboot_files_list = $jackboot_files_frame -> new_tk__listbox(-listvariable=>\$formatted_jackbootfiles, -width=>40, -height=>10);
	my $jackboot_files_scrollbar = $jackboot_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$jackboot_files_list, 'yview']);
	$jackboot_files_list -> configure(-yscrollcommand=>[$jackboot_files_scrollbar, 'set']);
	$jackboot_files_list -> g_grid(-row=>1, -column=>1);
	$jackboot_files_frame -> g_grid(-row=>1, -column=>1, -rowspan=>5);
	$jackboot_files_scrollbar -> g_grid(-row=>1, -column=>2, -sticky=>"ns");
	
	my $jackboot_runmaxent_chk = $mw -> new_ttk__checkbutton(-text=>"Run Maxent", -variable=>\$jackboot_runmaxent);
	$jackboot_runmaxent_chk -> g_grid (-row=>9, -column=>1, -columnspan=>5, -pady=>5);

	my $jackboot_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&jackbootExecute);
	$jackboot_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	
	push(@now_showing, ($description, $jackboot_list_label, $jackboot_list_addbutton, $jackboot_list_import, $jackboot_list_export, 
					$jackboot_list_clear, $jackboot_files_frame, $jackboot_files_list, $jackboot_files_scrollbar, $jackboot_runmaxent_chk, $jackboot_go_button)); 
					#Have to do push on this one because some widgets may not be defined
}

sub raiseCrossvalidationWindow{
	destroyEverything();
	my $description;
	my $crossvalidation_nreps_label = $mw -> new_ttk__label(-text=>"Number of replicates:  ");
	$crossvalidation_nreps_label -> g_grid(-row=>6, -column=>0, -pady=>10);
	our $crossvalidation_nreps_textbox = $mw -> new_ttk__entry();
	$crossvalidation_nreps_textbox -> g_grid(-row=>6, -column=>1, -pady=>10, -padx =>50);
	$crossvalidation_testprop_label = $mw -> new_ttk__label(-text=>"Proportion of records to retain for testing:  ");
	$crossvalidation_testprop_label -> g_grid(-row=>7, -column=>0, -pady=>10);
	$crossvalidation_testprop_textbox = $mw -> new_ttk__entry();
	$crossvalidation_testprop_textbox -> g_grid(-row=>7, -column=>1, -pady=>10, -padx =>50);
	push(@now_showing, ($crossvalidation_nreps_label, $crossvalidation_nreps_textbox, $crossvalidation_testprop_label, $crossvalidation_testprop_textbox)); 
	if($crossvalidation_breaktype eq "line"){
		$description = $mw->new_ttk__label(-text => "Split species along a straight line for cross-validation.");
	}
	if($crossvalidation_breaktype eq "blob"){
		$description = $mw->new_ttk__label(-text => "Partition the range of species for cross-validation using a polygon\ncentered around a randomly chosen occurrence point.");
	}
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $crossvalidation_list_label = $mw-> new_ttk__label(-text => "Files containing occurrences:  ");
	$crossvalidation_list_label -> g_grid(-row=>1, -column=>0);
	my $crossvalidation_list_addbutton = $mw -> new_ttk__button(-text=>"Add files",-width=>20, -command=>\&crossvalidationAddFiles);
	$crossvalidation_list_addbutton -> g_grid(-row=>2, -column=>0, -padx=>50);
	my $crossvalidation_list_import = $mw-> new_ttk__button(-text=>"Import file list", -width=>20, -command=>\&crossvalidationImportList);
	$crossvalidation_list_import -> g_grid(-row=>3, -column=>0, -padx=>50);
	my $crossvalidation_list_export = $mw-> new_ttk__button(-text=>"Save file list",-width=>20, -command=>\&crossvalidationExportList);
	$crossvalidation_list_export -> g_grid(-row=>4, -column=>0, -padx=>50);
	my $crossvalidation_list_clear = $mw-> new_ttk__button(-text=>"Clear file list", -width=>20, -command=>\&crossvalidationClearFiles);
	$crossvalidation_list_clear -> g_grid(-row=>5, -column=>0, -padx=>50);
	my $crossvalidation_files_frame = $mw-> new_ttk__frame();
	our $crossvalidation_files_list = $crossvalidation_files_frame -> new_tk__listbox(-listvariable=>\$formatted_crossvalidationfiles, -width=>40, -height=>10);
	my $crossvalidation_files_scrollbar = $crossvalidation_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$crossvalidation_files_list, 'yview']);
	$crossvalidation_files_list -> configure(-yscrollcommand=>[$crossvalidation_files_scrollbar, 'set']);
	$crossvalidation_files_list -> g_grid(-row=>1, -column=>1);
	$crossvalidation_files_frame -> g_grid(-row=>1, -column=>1, -rowspan=>5);
	$crossvalidation_files_scrollbar -> g_grid(-row=>1, -column=>2, -sticky=>"ns");
	
	my $crossvalidation_runmaxent_chk = $mw -> new_ttk__checkbutton(-text=>"Run Maxent", -variable=>\$crossvalidation_runmaxent);
	$crossvalidation_runmaxent_chk -> g_grid (-row=>9, -column=>1, -columnspan=>5, -pady=>5);

	my $crossvalidation_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&crossvalidationExecute);
	$crossvalidation_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	
	push(@now_showing, ($description, $crossvalidation_list_label, $crossvalidation_list_addbutton, $crossvalidation_list_import, $crossvalidation_list_export, 
					$crossvalidation_list_clear, $crossvalidation_files_frame, $crossvalidation_files_list, $crossvalidation_files_scrollbar, $crossvalidation_runmaxent_chk,
					$crossvalidation_go_button)); 
					#Have to do push on this one because some widgets may not be defined
}

sub raiseRastersampleWindow{
	destroyEverything();
	our $description = $mw->new_ttk__label(-text => "Resample from raster based on values");
	$description->g_grid(-columnspan=>2, -row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $rastersample_list_label = $mw-> new_ttk__label(-text => "ASCII raster files:  ");
	$rastersample_list_label -> g_grid();
	my $rastersample_list_addbutton = $mw -> new_ttk__button(-text=>"Add files",-width=>20, -command=>\&rastersampleAddFiles);
	$rastersample_list_addbutton -> g_grid(-row=>2, -column=>0, -padx=>50);
	my $rastersample_list_import = $mw-> new_ttk__button(-text=>"Import file list", -width=>20, -command=>\&rastersampleImportList);
	$rastersample_list_import -> g_grid(-row=>3, -column=>0, -padx=>50);
	my $rastersample_list_export = $mw-> new_ttk__button(-text=>"Save file list",-width=>20, -command=>\&rastersampleExportList);
	$rastersample_list_export -> g_grid(-row=>4, -column=>0, -padx=>50);
	my $rastersample_list_clear = $mw-> new_ttk__button(-text=>"Clear file list", -width=>20, -command=>\&rastersampleClearFiles);
	$rastersample_list_clear -> g_grid(-row=>5, -column=>0, -padx=>50);
	my $rastersample_files_frame = $mw-> new_ttk__frame();
	our $rastersample_files_list = $rastersample_files_frame -> new_tk__listbox(-listvariable=>\$formatted_rastersamplefiles, -width=>40, -height=>10);
	my $rastersample_files_scrollbar = $rastersample_files_frame -> new_ttk__scrollbar(-orient=>'vertical',-command=>[$rastersample_files_list, 'yview']);
	$rastersample_files_list -> configure(-yscrollcommand=>[$rastersample_files_scrollbar, 'set']);
	$rastersample_files_list -> g_grid(-row=>1, -column=>1);
	$rastersample_files_frame -> g_grid(-row=>1, -column=>1, -rowspan=>5);
	$rastersample_files_scrollbar -> g_grid(-row=>1, -column=>2, -sticky=>"ns");
	my $rastersample_npoints_label = $mw -> new_ttk__label(-text=>"Number of points per replicate:  ");
	$rastersample_npoints_label -> g_grid(-row=>6, -column=>0, -pady=>10);
	our $rastersample_npoints_textbox = $mw -> new_ttk__entry();
	$rastersample_npoints_textbox -> g_grid(-row=>6, -column=>1, -pady=>10, -padx =>50);
	my $rastersample_nreps_label = $mw -> new_ttk__label(-text=>"Number of replicates:  ");
	$rastersample_nreps_label -> g_grid(-row=>7, -column=>0, -pady=>10);
	our $rastersample_nreps_textbox = $mw -> new_ttk__entry();
	$rastersample_nreps_textbox -> g_grid(-row=>7, -column=>1, -pady=>10, -padx =>50);
	
	my $options_replace_frame = $mw-> new_ttk__frame();
	my $options_replace_label = $mw -> new_ttk__label(-text=>"Sample with replacement: ");
	my $options_replace_no = $options_replace_frame -> new_ttk__radiobutton(-text=>"No",  
			-value=>"no",  -variable=>\$rastersample_replace);
	my $options_replace_yes = $options_replace_frame -> new_ttk__radiobutton(-text=>"Yes",
			-value=>"yes",-variable=>\$rastersample_replace);
	$options_replace_label -> g_grid(-sticky=>"nwes",  -row=>8, -column=>0, -pady=>5, -padx=>10);
	$options_replace_no -> g_grid(-row=>1, -column=>1);
	$options_replace_yes -> g_grid(-row=>1, -column=>2);
	$options_replace_frame -> g_grid (-sticky=>"nwes", -row=>8, -column=>1, -columnspan=>3, -padx=>20);
	

	my $rastersample_functiontype_frame = $mw-> new_ttk__frame();
	my $rastersample_functiontype_label = $mw -> new_ttk__label(-text=>"Sampling function: ");
	my $rastersample_functiontype_constant = $rastersample_functiontype_frame -> new_ttk__radiobutton(-text=>"Constant",  
			-value=>"constant",  -variable=>\$rastersample_functiontype);
	my $rastersample_functiontype_linear = $rastersample_functiontype_frame -> new_ttk__radiobutton(-text=>"Linear",
			-value=>"linear",-variable=>\$rastersample_functiontype);
	my $rastersample_functiontype_exponential = $rastersample_functiontype_frame -> new_ttk__radiobutton(-text=>"Exponential",
			-value=>"exponential",-variable=>\$rastersample_functiontype);
	$rastersample_functiontype_label -> g_grid(-sticky=>"nwes",  -row=>9, -column=>0, -pady=>5, -padx=>10);
	$rastersample_functiontype_constant -> g_grid(-row=>1, -column=>1);
	$rastersample_functiontype_linear -> g_grid(-row=>1, -column=>2);
	$rastersample_functiontype_exponential -> g_grid(-row=>1, -column=>3);
	$rastersample_functiontype_frame -> g_grid (-sticky=>"nwes", -row=>9, -column=>1, -columnspan=>3, -padx=>20);
	
	my $rastersample_go_button = $mw -> new_ttk__button(-text=>"GO!", -width=>40, -command=>\&rastersampleExecute);
	$rastersample_go_button -> g_grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
	push(@now_showing, ($rastersample_go_button, $rastersample_nreps_textbox, $rastersample_nreps_label, $rastersample_npoints_textbox, $rastersample_npoints_label, $rastersample_files_frame,
	$rastersample_list_clear, $rastersample_list_export, $rastersample_list_import, $rastersample_list_addbutton, $rastersample_list_label, $description, $rastersample_functiontype_frame,
	$rastersample_functiontype_label, $options_replace_frame, $options_replace_label, $options_replace_no, $options_replace_yes)); 
}

sub raiseENMToolsOptionWindow{
	destroyEverything();
	our $description = $mw->new_ttk__label(-text => "Options specific to ENMTools.");
	$description->g_grid(-row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	my $options_layers_frame = $mw -> new_ttk__frame();
	my $options_layers_label = $mw -> new_ttk__label(-text=>"Source of climate data: ");
	$options_layers_label -> g_grid(-sticky=>"nwes", -row=>1, -column=>0, -pady=>5, -padx=>10);
	my $options_swd_rdb = $options_layers_frame -> new_ttk__radiobutton(-text=>"Species with data (csv)",  
			-value=>"CSV file",  -variable=>\$layers_type);
	my $options_layers_rdb = $options_layers_frame -> new_ttk__radiobutton(-text=>"Climate layers",
			-value=>"Layers directory",-variable=>\$layers_type);
	
	$options_swd_rdb -> g_grid(-row=>1, -column=>0);
	$options_layers_rdb -> g_grid(-row=>1, -column=>1);
	$options_layers_frame -> g_grid (-sticky=>"nwes", -row=>1, -column=>1, -columnspan=>3, -padx=>20);
	my $options_layers_button = $mw -> new_ttk__button(-textvariable => \$layers_type, 
			-command =>\&setLayersDir, -width=>20);
	$options_layers_button -> g_grid(-sticky=>"nwes", -row=>2, -column=>0, -pady=>5, -padx=>10);
	my $options_layers_text = $mw -> new_ttk__label(-textvariable=>\$layers_path, -justify=>"left", -wraplength=>400);
	$options_layers_text -> g_grid(-sticky=>"nwes", -row=>2, -column=>1, -padx=>20);
	
	my $options_output_directory_button = $mw -> new_ttk__button(-text => "Output directory", 
		-command =>\&optionsOutputDir, -width=>20);
	$options_output_directory_button -> g_grid(-sticky=>"nwes", -row=>3, -column=>0, -pady=>5, -padx=>10);
	my $options_output_directory_txt = $mw -> new_ttk__label(-textvariable=>\$output_directory, -justify=>"left", -wraplength=>400);
	$options_output_directory_txt -> g_grid(-sticky=>"nwes", -row=>3, -column=>1, -padx=>20);
	
	my $options_projection_directory_button = $mw -> new_ttk__button(-text=>"Projection directory", -width=>20, -command=>\&optionsProjectionDir);
	$options_projection_directory_button -> g_grid(-sticky=>"nwes",-row=>4, -column=>0, -padx=>10, -pady=>5);
	my $options_projection_text = $mw-> new_ttk__label(-textvariable=>\$projectiondir, -justify=>"left", -wraplength=>400);
	$options_projection_text -> g_grid(-sticky=>"nwes",-row=>4, -column=>1, -padx=>20);
	
	my $options_maxent_button = $mw -> new_ttk__button(-text => "Maxent .jar file", 
		-command =>\&setMaxentPath, -width=>20);
	$options_maxent_button -> g_grid(-sticky=>"nwes", -row=>5, -column=>0, -padx=>10, -pady=>5);
	my $options_maxent_text = $mw -> new_ttk__label(-textvariable=>\$maxent_path, -justify=>"left", -wraplength=>400);
	$options_maxent_text -> g_grid(-sticky=>"nwes", -row=>5, -column=>1, -padx=>20);
	
	my $options_biasfile_button = $mw -> new_ttk__button(-text => "Bias file", 
		-command =>\&setBiasfilePath, -width=>20);
	$options_biasfile_button -> g_grid(-sticky=>"nwes", -row=>6, -column=>0, -padx=>10, -pady=>5);
	my $options_biasfile_text = $mw -> new_ttk__label(-textvariable=>\$biasfile_path, -justify=>"left", -wraplength=>400);
	$options_biasfile_text -> g_grid(-sticky=>"nwes", -row=>6, -column=>1, -padx=>20);
	
	
	my $options_suitability_frame = $mw-> new_ttk__frame();
	my $options_suitability_label = $mw -> new_ttk__label(-text=>"Suitability measure: ");
	my $options_raw_rdb = $options_suitability_frame -> new_ttk__radiobutton(-text=>"Raw",  
			-value=>"raw",  -variable=>\$suitability_type);
	my $options_logistic_rdb = $options_suitability_frame -> new_ttk__radiobutton(-text=>"Logistic",
			-value=>"logistic",-variable=>\$suitability_type);
	my $options_cumulative_rdb = $options_suitability_frame -> new_ttk__radiobutton(-text=>"Cumulative",
			-value=>"cumulative",-variable=>\$suitability_type);
	$options_suitability_label -> g_grid(-sticky=>"nwes", -row=>7, -column=>0, -pady=>5, -padx=>10);
	$options_raw_rdb -> g_grid(-row=>1, -column=>0,-padx=>5);
	$options_logistic_rdb -> g_grid(-row=>1, -column=>1,-padx=>5);
	$options_cumulative_rdb -> g_grid(-row=>1, -column=>2,-padx=>5);
	$options_suitability_frame -> g_grid (-sticky=>"nwes", -row=>7, -column=>1, -columnspan=>3, -padx=>20);
		
	my $options_show_maxent_frame = $mw-> new_ttk__frame();
	my $options_show_maxent_label = $mw -> new_ttk__label(-text=>"Show Maxent GUI: ");
	my $options_show_maxent_no = $options_show_maxent_frame -> new_ttk__radiobutton(-text=>"No",  
			-value=>"no",  -variable=>\$options_show_maxent);
	my $options_show_maxent_yes = $options_show_maxent_frame -> new_ttk__radiobutton(-text=>"Yes",
			-value=>"yes",-variable=>\$options_show_maxent);
	$options_show_maxent_label -> g_grid(-sticky=>"nwes",  -row=>8, -column=>0, -pady=>5, -padx=>10);
	$options_show_maxent_no -> g_grid(-row=>1, -column=>1);
	$options_show_maxent_yes -> g_grid(-row=>1, -column=>2);
	$options_show_maxent_frame -> g_grid (-sticky=>"nwes", -row=>8, -column=>1, -columnspan=>3, -padx=>20);
	
	my $options_large_overlap_frame = $mw-> new_ttk__frame();
	my $options_large_overlap_label = $mw -> new_ttk__label(-text=>"Large file overlap/breadth: ");
	my $options_large_overlap_no = $options_large_overlap_frame -> new_ttk__radiobutton(-text=>"No",  
			-value=> 0,  -variable=>\$large_overlap);
	my $options_large_overlap_yes = $options_large_overlap_frame -> new_ttk__radiobutton(-text=>"Yes",
			-value=> 1,-variable=>\$large_overlap);
	$options_large_overlap_label -> g_grid(-sticky=>"nwes",  -row=>9, -column=>0, -pady=>5, -padx=>10);
	$options_large_overlap_no -> g_grid(-row=>1, -column=>1);
	$options_large_overlap_yes -> g_grid(-row=>1, -column=>2);
	$options_large_overlap_frame -> g_grid (-sticky=>"nwes", -row=>9, -column=>1, -columnspan=>3, -padx=>20);
	
	my $options_maxent_version_frame = $mw-> new_ttk__frame();
	my $options_maxent_version_label = $mw -> new_ttk__label(-text=>"Maxent version: ");
	my $options_maxent_version_old = $options_maxent_version_frame -> new_ttk__radiobutton(-text=>"3.2.x or older",  
			-value=>"old",  -variable=>\$options_maxent_version);
	my $options_maxent_version_new = $options_maxent_version_frame -> new_ttk__radiobutton(-text=>"3.3 or newer",
			-value=>"new",-variable=>\$options_maxent_version);
	$options_maxent_version_label -> g_grid(-sticky=>"nwes",  -row=>10, -column=>0, -pady=>5, -padx=>10);
	$options_maxent_version_old -> g_grid(-row=>1, -column=>1);
	$options_maxent_version_new -> g_grid(-row=>1, -column=>2);
	$options_maxent_version_frame -> g_grid (-sticky=>"nwes", -row=>10, -column=>1, -columnspan=>3, -padx=>20);
	
	my $options_save_button = $mw-> new_ttk__button(-text=>"Save options",  -command=>\&saveConfig);
	$options_save_button -> g_grid(-row=>15, -column=>1, -columnspan=>3, -pady=>40);
	
	
	@now_showing = ($description, $options_layers_frame, $options_layers_label, $options_layers_button, $options_layers_text, 
					$options_output_directory_button, $options_output_directory_txt, $options_projection_directory_button, 
					$options_projection_text, $options_maxent_button, $options_maxent_text, $options_suitability_frame, 
					$options_suitability_label, $options_show_maxent_label, $options_show_maxent_frame, $options_maxent_version_frame,
					$options_large_overlap_label, $options_large_overlap_frame,	$options_large_overlap_no, $options_large_overlap_yes, 
					$options_maxent_version_label, $options_save_button, $options_biasfile_button, $options_biasfile_text,
					$options_maxent_version_old, $options_maxent_version_new);
}

sub raiseMaxentOptionWindow{
	destroyEverything();
	our $description = $mw->new_ttk__label(-text => "Options for Maxent.");
	$description->g_grid(-row=>0, -padx=>5, -pady=>20, -sticky=>"w");
	
	my $options_memory_label = $mw-> new_ttk__label(-text=>"RAM to assign to Maxent (MB):  ");
	$options_memory_label -> g_grid(-sticky=>"nwes", -row=>1, -column=>0, -pady=>10, -padx=>10);
	my $options_memory_textbox = $mw -> new_ttk__entry(-textvariable=>\$memory);
	$options_memory_textbox -> g_grid(-sticky=>"nwes", -row=>1, -column=>1, -pady=>10, -padx =>5);
	
	my $options_beta_label = $mw-> new_ttk__label(-text=>"Regularization parameter (beta):  ");
	$options_beta_label -> g_grid(-sticky=>"nwes", -row=>3, -column=>0, -pady=>10, -padx=>10);
	my $options_beta_textbox = $mw -> new_ttk__entry(-textvariable=>\$maxent_beta);
	$options_beta_textbox -> g_grid(-sticky=>"nwes", -row=>3, -column=>1, -pady=>10, -padx =>5);
	
	my $options_pictures_frame = $mw-> new_ttk__frame();
	my $options_pictures_label = $mw -> new_ttk__label(-text=>"Make pictures for ENMs: ");
	my $options_pictures_no = $options_pictures_frame -> new_ttk__radiobutton(-text=>"No",  
			-value=>"",  -variable=>\$pictures);
	my $options_pictures_yes = $options_pictures_frame -> new_ttk__radiobutton(-text=>"Yes",
			-value=>"pictures",-variable=>\$pictures);
	$options_pictures_label -> g_grid(-sticky=>"nwes",  -row=>4, -column=>0, -pady=>5, -padx=>10);
	$options_pictures_no -> g_grid(-row=>1, -column=>1);
	$options_pictures_yes -> g_grid(-row=>1, -column=>2);
	$options_pictures_frame -> g_grid (-sticky=>"nwes", -row=>4, -column=>1, -columnspan=>3, -padx=>20);
	
	my $options_rocplots_frame = $mw-> new_ttk__frame();
	my $options_rocplots_label = $mw -> new_ttk__label(-text=>"Make ROC plots for ENMs: ");
	my $options_rocplots_no = $options_rocplots_frame -> new_ttk__radiobutton(-text=>"No",  
			-value=>"noplots",  -variable=>\$rocplots);
	my $options_rocplots_yes = $options_rocplots_frame -> new_ttk__radiobutton(-text=>"Yes",
			-value=>"",-variable=>\$rocplots);
	$options_rocplots_label -> g_grid(-sticky=>"nwes",  -row=>5, -column=>0, -pady=>5, -padx=>10);
	$options_rocplots_no -> g_grid(-row=>1, -column=>1);
	$options_rocplots_yes -> g_grid(-row=>1, -column=>2);
	$options_rocplots_frame -> g_grid (-sticky=>"nwes", -row=>5, -column=>1, -columnspan=>3, -padx=>20);
	
	my $options_responsecurves_frame = $mw-> new_ttk__frame();
	my $options_responsecurves_label = $mw -> new_ttk__label(-text=>"Make response curves for ENMs: ");
	my $options_responsecurves_no = $options_responsecurves_frame -> new_ttk__radiobutton(-text=>"No",  
			-value=>"",  -variable=>\$responsecurves);
	my $options_responsecurves_yes = $options_responsecurves_frame -> new_ttk__radiobutton(-text=>"Yes",
			-value=>"responsecurves",-variable=>\$responsecurves);
	$options_responsecurves_label -> g_grid(-sticky=>"nwes",  -row=>6, -column=>0, -pady=>5, -padx=>10);
	$options_responsecurves_no -> g_grid(-row=>1, -column=>1);
	$options_responsecurves_yes -> g_grid(-row=>1, -column=>2);
	$options_responsecurves_frame -> g_grid (-sticky=>"nwes", -row=>6, -column=>1, -columnspan=>3, -padx=>20);
	
	my $options_removedupes_frame = $mw-> new_ttk__frame();
	my $options_removedupes_label = $mw -> new_ttk__label(-text=>"Remove duplicates: ");
	my $options_removedupes_no = $options_removedupes_frame -> new_ttk__radiobutton(-text=>"No",  
			-value=>"",  -variable=>\$removedupes);
	my $options_removedupes_yes = $options_removedupes_frame -> new_ttk__radiobutton(-text=>"Yes",
			-value=>"removeduplicates",-variable=>\$removedupes);
	$options_removedupes_label -> g_grid(-sticky=>"nwes",  -row=>7, -column=>0, -pady=>5, -padx=>10);
	$options_removedupes_no -> g_grid(-row=>1, -column=>1);
	$options_removedupes_yes -> g_grid(-row=>1, -column=>2);
	$options_removedupes_frame -> g_grid (-sticky=>"nwes", -row=>7, -column=>1, -columnspan=>3, -padx=>20);
	
	my $options_save_button = $mw-> new_ttk__button(-text=>"Save options",  -command=>\&saveConfig);
	$options_save_button -> g_grid(-row=>20, -column=>1, -columnspan=>3, -pady=>100);
	
	@now_showing = ($description, $options_save_button, $options_memory_label, $options_memory_textbox, $options_beta_label, $options_beta_textbox, $options_pictures_frame, $options_pictures_label,
	$options_responsecurves_frame, $options_responsecurves_label, $options_removedupes_frame, $options_removedupes_label, $options_rocplots_frame, $options_rocplots_label);
}

sub raiseAboutWindow{
	Tkx::tk___messageBox(-message => "Have a good day");
}

sub destroyEverything{
	for(my $i = 0; $i < @now_showing; $i++){
		#print "Destroying $now_showing[$i]\n";
		$now_showing[$i]->g_destroy();
	}
	@now_showing = ();
}


##### Functions for use in the overlap tab
sub overlapAddFiles {
    my $addfiles;
    for (@overlap_files){
    	$addfiles = $addfiles . " {$_}";
    }
    my $newfiles = Tkx::tk___getOpenFile(-multiple=>TRUE);
    unless($newfiles =~ /\}\s+\{/ || $newfiles =~ /^\{/){  # All of this shit is just to make sure that file names are parsed consistently.  ARGH TKX. WTF.
    	$newfiles =~ s/\s+/} {/g;
    	$newfiles = "{" . $newfiles . "}";
    }
    $addfiles = $addfiles . " " . $newfiles;
    $addfiles =~ s/^\s+//;
    @overlap_files = ();
    $formatted_overlapfiles = "";
    #Tkx::tk___messageBox(-message=>"$addfiles");
    my @thesefiles = split(/}\s+{/, $addfiles);
    for(@thesefiles){
    	$_ =~ s/\{//;
    	$_ =~ s/\}//;
    	push (@overlap_files, $_);
    	my @thisname = split(/\//, $_);
    	$formatted_overlapfiles = $formatted_overlapfiles . " {$thisname[-1]} ";
    }
}


sub overlapClearFiles {
    @overlap_files = ();
    $formatted_overlapfiles = "";
}

sub overlapImportList{
    @overlap_files=();
    $formatted_overlapfiles = "";
    my $importfile = Tkx::tk___getOpenFile();
    open(IMPORT, "$importfile");
    while(<IMPORT>) {
        my $thisfile = $_;
        chomp($thisfile);
        push(@overlap_files, $thisfile);
        my @thisname = split(/\//, $thisfile);
    	$formatted_overlapfiles = $formatted_overlapfiles . " {$thisname[-1]} ";
    }
}

sub overlapExportList{
    my $exportfile = Tkx::tk___getSaveFile();
    open(EXPORT, ">$exportfile");
    for(@overlap_files){print EXPORT "$_\n";}
    close EXPORT;
}

sub overlapManual {  ###Makes sure everything is order before running the overlap script
    $fileprefix = $overlap_name_textbox ->get(); #It's an entry widget
    if(!$fileprefix){
        Tkx::tk___messageBox(-message=>"You need to name this analysis, so that output files can be generated.");
    }
    elsif(!@overlap_files){
        Tkx::tk___messageBox(-message=>"You need to pick some files.");
    }
    elsif ($output_directory =~ /^directory not set/i) {
        Tkx::tk___messageBox(-message=>"You need to specify an output directory.");
    }
    else{overlapExecute();}
    Tkx::tk___messageBox(-message=>"Analysis \"$fileprefix\" is finished.");
}

sub pairwiseOverlap{
	my $listfile = Tkx::tk___getOpenFile();
	if(-e $listfile){
		my @thisname = split(/\//, $listfile);
		my $outfile = $thisname[-1];
		$outfile = $output_directory . "/" . $outfile;
		$outfile =~ s/\.csv$/_output.csv/;
		open(OUTFILE, ">$outfile") || die "Can't write to $outfile!\n";
		open(INFILE, "$listfile") || die "Can't read $listfile!\n";
		if($large_overlap == 0){print OUTFILE "File 1,File 2,I,D,Relative Rank\n";}
        else{print OUTFILE "File 1,File 2,I,D\n";}
		while(<INFILE>){
			chomp($_);
            print OUTFILE "$_";
			my @thisline = split(/,/, $_);
			if(-e $thisline[0] && -e $thisline[1]){
				my $numcells = 0;
                my $sum3 = 0;
                my $sum4 = 0;
                my $iscore = 0;
                my $dscore = 0;
                my $relrankscore = 0;
                my @rankarray;
                if($large_overlap == 0){
                    open(FILE1, $thisline[0]);
                    open(FILE2, $thisline[1]);
                    my @file1 = <FILE1>;
                    my @file2 = <FILE2>;
                    close FILE1;
                    close FILE2;
                    print "Comparing $thisline[0] and $thisline[1]\n";
                    my $warning = "no";
                    for(my $k = 0; $k < @file1; $k++){   #####  Cycle through to get sum for all point probabilities in each file  #####
                        #$file2[$k] =~ s/\r/\n/g;
                        #$file1[$k] =~ s/\r/\n/g;
                        if((($file1[$k] =~ /^\s*\d/ ) || ($file1[$k] =~ /^\s*-/ ) ) && (($file2[$k] =~ /^\s*\d/ )|| ($file2[$k] =~ /^\s*-/ ))){
                            my @line1 = split(/\s+/, $file1[$k]);
                            my @line2 = split(/\s+/, $file2[$k]);
                            for(my $l = 0; $l < @line1; $l++){
                               unless(exists($line2[$l])){print LOGFILE "Problem at $k, $l\n";}
                               if($line1[$l] ne "-9999"){
                                   $sum3 += $line1[$l];
                                   if ($line1[$l] > 1){$warning = "yes";}
                                }
                               if($line2[$l] ne "-9999"){
                                   $sum4 += $line2[$l];
                                   if ($line2[$l] > 1){$warning = "yes";}
                                }
                           }
                       }
                    }
                    print "$sum3\t$sum4\n\n";
                    my $columns = 0;
                    my $rows = 0;
                    my $sum1 = 0;
                    my $sum2 = 0;
                    for(my $k = 0; $k < @file1; $k++){
                        #print "$file1[$k]\t$file2[$k]\n";
                        if((($file1[$k] =~ /^\s*\d/ ) || ($file1[$k] =~ /^\s*-/ ) ) && (($file2[$k] =~ /^\s*\d/ )|| ($file2[$k] =~ /^\s*-/ ))){
                            my @line1 = split(/\s+/, $file1[$k]);
                            my @line2 = split(/\s+/, $file2[$k]);
                            $columns = 0;
                            for(my $l = 0; $l < @line1; $l++){
                                if($line1[$l] !~ /-9999/ && $line2[$l] !~ /-9999/){
                                    my $twoscores = "$line1[$l],$line2[$l]";
                                    push (@rankarray, $twoscores);
                                    my $tempvar = 0;
                                    $sum1 += $line1[$l]/$sum3;
                                    $sum2 += $line2[$l]/$sum4;
                                    #####  Calculate bits for Hellinger #####
                                    my $tempvar2 = sqrt($line1[$l]/$sum3) - sqrt($line2[$l]/$sum4);
                                    $tempvar2 = $tempvar2 * $tempvar2;
                                    $iscore += $tempvar2;
                                    my $tempvar3 = ($line1[$l]/$sum3) - ($line2[$l]/$sum4);
                                    if ($tempvar3 < 0){$tempvar3 = 0 - $tempvar3;}
                                    $dscore += $tempvar3;
                                }
                                $numcells++;
                                $columns++;
                            }
                        }
                        $rows++;
                    }
                    fisher_yates_shuffle(\@rankarray);
                    for(my $k = 0; $k < @rankarray; $k+= 2){
                      my @rankline1 = split(/,/, $rankarray[$k]);
                      my @rankline2 = split(/,/, $rankarray[$k+1]);
                      if(exists($rankline1[0]) && exists($rankline2[0]) && exists($rankline1[1]) && exists($rankline2[1]) ){
                        if($rankline1[0] == $rankline2[0] && $rankline1[1] == $rankline2[1] ){
                          $relrankscore++;
                          #print "match: $rankline1[0] >= $rankline2[0] && $rankline1[1] >= $rankline2[1]\n";
                        }
                        if($rankline1[0] > $rankline2[0] && $rankline1[1] > $rankline2[1] ){
                          $relrankscore++;
                          #print "match: $rankline1[0] >= $rankline2[0] && $rankline1[1] >= $rankline2[1]\n";
                        }
                        elsif($rankline1[0] < $rankline2[0] && $rankline1[1] < $rankline2[1] ){
                          $relrankscore++;
                          #print "match: $rankline1[0] < $rankline2[0] && $rankline1[1] < $rankline2[1]\n";
                        }
                        else{
                          #print "mismatch: $rankline1[0] X $rankline2[0] && $rankline1[1] X $rankline2[1]\n";
                        }
                      }
                    }
                }
                else{ #Large matrices
					open(FILE1, $thisline[0]);
                    open(FILE2, $thisline[1]);
				  	print "Comparing $thisline[0] and $thisline[1]\n";
				  	my $warning = "no";
				  	while(<FILE1>){   #####  Cycle through to get sum for all point probabilities in each file  #####
                        my $line1 = $_;
                        #print "$line1";
                        my $line2 = <FILE2>;
                        if((($line1 =~ /^\s*\d/ ) || ($line1 =~ /^\s*-/ ) ) && (($line2 =~ /^\s*\d/ )|| ($line2 =~ /^\s*-/ ))){
                            my @splitline1 = split(/\s+/, $line1);
                            my @splitline2 = split(/\s+/, $line2);
                            for(my $l = 0; $l < @splitline1; $l++){
                                unless(exists($splitline2[$l])){print LOGFILE "Problem at $k, $l\n";}
                                if($splitline1[$l] ne "-9999"){
                                    $sum3 += $splitline1[$l];
                                    #if ($splitline1[$l] > 1 || $splitline1[$l] < 0){
                                    #    die "Found suitability score of $splitline1[$l]!\n";
                                    #}
                                }
                                if($splitline2[$l] ne "-9999"){
                                    $sum4 += $splitline2[$l];
                                    #if ($splitline2[$l] > 1 || $splitline2[$l] < 0){
                                    #    die "Found suitability score of $splitline2[$l]!\n";
                                    #}
                                }
                            }
                        }
                    }
                    print "$sum3\t$sum4\n\n";
                    close FILE1;
                    close FILE2;
                    open(FILE1, $thisline[0]);
                    open(FILE2, $thisline[1]);
                    my $columns = 0;
                    my $rows = 0;
                    my $sum1 = 0;
                    my $sum2 = 0;
                    while(<FILE1>){
                        my $line1 = $_;
                        my $line2 = <FILE2>;
                        if((($line1 =~ /^\s*\d/ ) || ($line1 =~ /^\s*-/ ) ) && (($line2 =~ /^\s*\d/ )|| ($line2 =~ /^\s*-/ ))){
                            my @splitline1 = split(/\s+/, $line1);
                            my @splitline2 = split(/\s+/, $line2);
                            $columns = 0;
                            for(my $l = 0; $l < @splitline1; $l++){
                                if($splitline1[$l] !~ /-9999/ && $splitline2[$l] !~ /-9999/){
                                    my $tempvar = 0;
                                    $sum1 += $splitline1[$l]/$sum3;
                                    $sum2 += $splitline2[$l]/$sum4;
                                    #####  Calculate bits for Hellinger #####
                                    my $tempvar2 = sqrt($splitline1[$l]/$sum3) - sqrt($splitline2[$l]/$sum4);
                                    $tempvar2 = $tempvar2 * $tempvar2;
                                    $iscore += $tempvar2;
                                    my $tempvar3 = ($splitline1[$l]/$sum3) - ($splitline2[$l]/$sum4);
                                    if ($tempvar3 < 0){$tempvar3 = 0 - $tempvar3;}
                                    $dscore += $tempvar3;
                                }
                                $numcells++;
                                $columns++;
                            }
                        }
                        $rows++;
                    }
				}
                print "Check: Sum1: $sum1\t Sum2: $sum2\n";
                print "Number of cells = $numcells\n";
                print "$columns columns, $rows rows.\n\n\n";
                #$iscore = sqrt($iscore);
                $iscore = 1 - ($iscore/2);
                $dscore = 1 - ($dscore/2);
                if($iscore < .0000000001){$iscore = 0;}
                if($dscore < .0000000001){$dscore = 0;}
                #print "$relrankscore\n";
                if($large_overlap == 0){$relrankscore = $relrankscore/(@rankarray/2);}
                #print "$relrankscore\n";
				close FILE1;
				close FILE2;
				if($large_overlap == 0){print OUTFILE ",$iscore,$dscore,$relrankscore\n";}
                else{print OUTFILE ",$iscore,$dscore\n";}
			}
			else{print OUTFILE "$_,file not found,file not found\n";}
		}
		close OUTFILE;
		print "Results from $listfile written to $outfile!";
	}
}

sub overlapExecute{
#This is where the guts of the overlap script are executed
#Wants to see files to compare in array @overlap_files and wants a name in $fileprefix
    #####  PRINT HEADER LINE  #####
    my @shortnames;
    for (@overlap_files) {
        my @thisname = split(/\//, $_);
        push (@shortnames, $thisname[-1]);
    }
    
    my $ioutfile = $output_directory . "/". $fileprefix . "_I_output.csv";
    open(IOUTFILE, ">$ioutfile") || die "\n\nCan't write to $ioutfile\n\n";
    print IOUTFILE "SPECIES";
    for(my $i = 0; $i < @shortnames; $i++){
        my $thisfile = $shortnames[$i];
        chomp($thisfile);
        print IOUTFILE ",$thisfile";
    }
    print IOUTFILE "\n";
    
    my $doutfile = $output_directory . "/". $fileprefix . "_D_output.csv";
    open(DOUTFILE, ">$doutfile") || die "\n\nCan't write to $doutfile\n\n";
    print DOUTFILE "SPECIES";
    for(my $i = 0; $i < @shortnames; $i++){
        my $thisfile = $shortnames[$i];
        chomp($thisfile);
        print DOUTFILE ",$thisfile";
    }
    print DOUTFILE "\n";
    
    if($large_overlap == 0){ #Not doing rel rank with large matrices
    	my $relrankoutfile = $output_directory . "/". $fileprefix . "_relrank_output.csv";
		open(RELRANKOUTFILE, ">$relrankoutfile") || die "\n\nCan't write to $relrankoutfile\n\n";
		print RELRANKOUTFILE "SPECIES";
		for(my $i = 0; $i < @shortnames; $i++){
			my $thisfile = $shortnames[$i];
			chomp($thisfile);
			print RELRANKOUTFILE ",$thisfile";
		}
		print RELRANKOUTFILE "\n";
    }
    
    #print "In overlapExecute, using $ioutfile and $doutfile\n";
    for(my $i = 0; $i < @overlap_files; $i++){
        print IOUTFILE "$shortnames[$i],";
        print DOUTFILE "$shortnames[$i],";
        if($large_overlap == 0){print RELRANKOUTFILE "$shortnames[$i],";}
        for(my $j = 0; $j < @overlap_files; $j++){
            if($i < $j){
            	open (LOGFILE, ">logfile.txt");
                my $numcells = 0;
                my $sum3 = 0;
                my $sum4 = 0;
                my $iscore = 0;
                my $dscore = 0;
                my $relrankscore = 0;
                my @rankarray;
                if($large_overlap == 0){
					open(TEMP1, $overlap_files[$i]) || die "\n\nCan't open $overlap_files[$i]!!\n\n";
					open(TEMP2, $overlap_files[$j]) || die "\n\nCan't open $overlap_files[$j]!!\n\n";
					my @file1 = <TEMP1>;
					my @file2 = <TEMP2>;
					close TEMP1;
					close TEMP2;
					#my $file1 = $overlap_files[$i] . ".table";
					#my $file2 = $overlap_files[$j] . ".table";
					#open (TABLE1, ">$file1");
					#open (TABLE2, ">$file2");
					print "Comparing $overlap_files[$i] and $overlap_files[$j] using small matrix overlaps\n";
					my $warning = "no";
					for(my $k = 0; $k < @file1; $k++){   #####  Cycle through to get sum for all point probabilities in each file  #####
						#$file1[$k] =~ s/\r/\n/g;
						#$file2[$k] =~ s/\r/\n/g;
						if((($file1[$k] =~ /^\s*\d/ ) || ($file1[$k] =~ /^\s*-/ ) ) && (($file2[$k] =~ /^\s*\d/ )|| ($file2[$k] =~ /^\s*-/ ))){
							my @line1 = split(/\s+/, $file1[$k]);
							my @line2 = split(/\s+/, $file2[$k]);
							for(my $l = 0; $l < @line1; $l++){
							   unless(exists($line2[$l])){print LOGFILE "Problem at $k, $l\n";}
							   if($line1[$l] ne "-9999"){
								   $sum3 += $line1[$l];
								   if ($line1[$l] > 1){$warning = "yes";}
								   #print TABLE1 "$line1[$l]\n";
								}
							   if($line2[$l] ne "-9999"){
									
								   $sum4 += $line2[$l];
								   if ($line2[$l] > 1){$warning = "yes";}
								   #print TABLE2 "$line2[$l]\n";
								}
						   }
					   }
					}
					close LOGFILE;
					print "$sum3\t$sum4\n\n";
					my $columns = 0;
					my $rows = 0;
					#close TABLE1;
					#close TABLE2;
					my $sum1 = 0;
					my $sum2 = 0;
					for(my $k = 0; $k < @file1; $k++){
						#print "$file1[$k]\t$file2[$k]\n";
						if((($file1[$k] =~ /^\s*\d/ ) || ($file1[$k] =~ /^\s*-/ ) ) && (($file2[$k] =~ /^\s*\d/ )|| ($file2[$k] =~ /^\s*-/ ))){
							my @line1 = split(/\s+/, $file1[$k]);
							my @line2 = split(/\s+/, $file2[$k]);
							$columns = 0;
							for(my $l = 0; $l < @line1; $l++){
								if($line1[$l] !~ /-9999/ && $line2[$l] !~ /-9999/){
									my $twoscores = "$line1[$l],$line2[$l]";
									push (@rankarray, $twoscores);
									my $tempvar = 0;
									$sum1 += $line1[$l]/$sum3;
									$sum2 += $line2[$l]/$sum4;
									#####  Calculate bits for Hellinger #####
									my $tempvar2 = sqrt($line1[$l]/$sum3) - sqrt($line2[$l]/$sum4);
									$tempvar2 = $tempvar2 * $tempvar2;
									$iscore += $tempvar2;
									my $tempvar3 = ($line1[$l]/$sum3) - ($line2[$l]/$sum4);
									if ($tempvar3 < 0){$tempvar3 = 0 - $tempvar3;}
									$dscore += $tempvar3;
								}
								$numcells++;
								$columns++;
							}
						}
						$rows++;
					}
					fisher_yates_shuffle(\@rankarray);
					
					for(my $k = 0; $k < @rankarray; $k+= 2){
					  my @rankline1 = split(/,/, $rankarray[$k]);
					  my @rankline2 = split(/,/, $rankarray[$k+1]);
					  if(exists($rankline1[0]) && exists($rankline2[0]) && exists($rankline1[1]) && exists($rankline2[1]) ){
						if($rankline1[0] == $rankline2[0] && $rankline1[1] == $rankline2[1] ){
						  $relrankscore++;
						  #print "match: $rankline1[0] >= $rankline2[0] && $rankline1[1] >= $rankline2[1]\n";
						}
						if($rankline1[0] > $rankline2[0] && $rankline1[1] > $rankline2[1] ){
						  $relrankscore++;
						  #print "match: $rankline1[0] >= $rankline2[0] && $rankline1[1] >= $rankline2[1]\n";
						}
						elsif($rankline1[0] < $rankline2[0] && $rankline1[1] < $rankline2[1] ){
						  $relrankscore++;
						  #print "match: $rankline1[0] < $rankline2[0] && $rankline1[1] < $rankline2[1]\n";
						}
						else{
						  #print "mismatch: $rankline1[0] X $rankline2[0] && $rankline1[1] X $rankline2[1]\n";
						}
					  }
					}
				}
				else{ #Large matrices
					open(FILE1, $overlap_files[$i]);
				  	open(FILE2, $overlap_files[$j]);
				  	print "Comparing $overlap_files[$i] and $overlap_files[$j] using large matrix overlaps\n";
				  	my $warning = "no";
				  	while(<FILE1>){   #####  Cycle through to get sum for all point probabilities in each file  #####
					  my $line1 = $_;
					  #print "$line1";
					  my $line2 = <FILE2>;
					  if((($line1 =~ /^\s*\d/ ) || ($line1 =~ /^\s*-/ ) ) && (($line2 =~ /^\s*\d/ )|| ($line2 =~ /^\s*-/ ))){
						  my @splitline1 = split(/\s+/, $line1);
						  my @splitline2 = split(/\s+/, $line2);
						  for(my $l = 0; $l < @splitline1; $l++){
							 unless(exists($splitline2[$l])){print LOGFILE "Problem at $k, $l\n";}
							 if($splitline1[$l] ne "-9999"){
								 $sum3 += $splitline1[$l];
								 #if ($splitline1[$l] > 1 || $splitline1[$l] < 0){
                                 #	die "Found suitability score of $splitline1[$l]!\n";
								 #}
							  }
							 if($splitline2[$l] ne "-9999"){
								 $sum4 += $splitline2[$l];
								 #if ($splitline2[$l] > 1 || $splitline2[$l] < 0){
                                 #	die "Found suitability score of $splitline2[$l]!\n";
								 #}
							  }
						 }
					 }
				  }
				  print "$sum3\t$sum4\n\n";
				  close FILE1;
				  close FILE2;
				  open(FILE1, $overlap_files[$i]);
				  open(FILE2, $overlap_files[$j]);
				  my $columns = 0;
				  my $rows = 0;
				  my $sum1 = 0;
				  my $sum2 = 0;
				  while(<FILE1>){
					  my $line1 = $_;
					  my $line2 = <FILE2>;
					  if((($line1 =~ /^\s*\d/ ) || ($line1 =~ /^\s*-/ ) ) && (($line2 =~ /^\s*\d/ )|| ($line2 =~ /^\s*-/ ))){
						  my @splitline1 = split(/\s+/, $line1);
						  my @splitline2 = split(/\s+/, $line2);
						  $columns = 0;
						  for(my $l = 0; $l < @splitline1; $l++){
							  if($splitline1[$l] !~ /-9999/ && $splitline2[$l] !~ /-9999/){
								  my $tempvar = 0;
								  $sum1 += $splitline1[$l]/$sum3;
								  $sum2 += $splitline2[$l]/$sum4;
								  #####  Calculate bits for Hellinger #####
								  my $tempvar2 = sqrt($splitline1[$l]/$sum3) - sqrt($splitline2[$l]/$sum4);
								  $tempvar2 = $tempvar2 * $tempvar2;
								  $iscore += $tempvar2;
								  my $tempvar3 = ($splitline1[$l]/$sum3) - ($splitline2[$l]/$sum4);
								  if ($tempvar3 < 0){$tempvar3 = 0 - $tempvar3;}
								  $dscore += $tempvar3;
							  }
							  $numcells++;
							  $columns++;
						  }
					  }
					  $rows++;
				  }
				}
                print "Check: Sum1: $sum1\t Sum2: $sum2\n";
                print "Number of cells = $numcells\n";
                print "$columns columns, $rows rows.\n\n\n";
                #$iscore = sqrt($iscore);
                $iscore = 1 - ($iscore/2);
                $dscore = 1 - ($dscore/2);
                if($large_overlap == 0){$relrankscore = $relrankscore/(@rankarray/2);}
                if($iscore < .0000000001){$iscore = 0;}
                if($dscore < .0000000001){$dscore = 0;}
                if($j == (@overlap_files-1)){  #####  Last value in line  
                    print IOUTFILE "$iscore\n";
                    print DOUTFILE "$dscore\n";
                    if($large_overlap == 0){print RELRANKOUTFILE "$relrankscore\n";}
                }
                else{
                    print IOUTFILE "$iscore,";
                    print DOUTFILE "$dscore,";
                    if($large_overlap == 0){print RELRANKOUTFILE "$relrankscore,";}
                }
                
            }
            elsif($i > $j){
                print IOUTFILE "x,";
                print DOUTFILE "x,";
                if($large_overlap == 0){print RELRANKOUTFILE "x,";}
            }
            else{
                if($j == (@overlap_files-1)){  #####  Last value in line  
                    print IOUTFILE "1\n";
                    print DOUTFILE "1\n";
                    if($large_overlap == 0){print RELRANKOUTFILE "1\n";}
                }
                else{
                    print IOUTFILE "1,";
                    print DOUTFILE "1,";
                    if($large_overlap == 0){print RELRANKOUTFILE "1,";}
                }
            
            }
        }
    }
    close IOUTFILE;
    close DOUTFILE;
    if($large_overlap == 0){close RELRANKOUTFILE;}
}


##### Functions for use in measuring niche breadth
sub breadthAddFiles {
    my $addfiles;
    for (@breadth_files){
    	$addfiles = $addfiles . " {$_}";
    }
    my $newfiles = Tkx::tk___getOpenFile(-multiple=>TRUE);
    unless($newfiles =~ /\}\s+\{/ || $newfiles =~ /^\{/){  # All of this shit is just to make sure that file names are parsed consistently.  ARGH TKX. WTF.
    	$newfiles =~ s/\s+/} {/g;
    	$newfiles = "{" . $newfiles . "}";
    }
    $addfiles = $addfiles . " " . $newfiles;
    $addfiles =~ s/^\s+//;
    @breadth_files = ();
    $formatted_breadthfiles = "";
    #Tkx::tk___messageBox(-message=>"$addfiles");
    my @thesefiles = split(/}\s+{/, $addfiles);
    for(@thesefiles){
    	$_ =~ s/\{//;
    	$_ =~ s/\}//;
    	push (@breadth_files, $_);
    	my @thisname = split(/\//, $_);
    	$formatted_breadthfiles = $formatted_breadthfiles . " {$thisname[-1]} ";
    }
}


sub breadthClearFiles {
    @breadth_files = ();
    $formatted_breadthfiles = "";
}

sub breadthImportList{
    @breadth_files=();
    $formatted_breadthfiles = "";
    my $importfile = Tkx::tk___getOpenFile();
    open(IMPORT, "$importfile");
    while(<IMPORT>) {
        my $thisfile = $_;
        chomp($thisfile);
        push(@breadth_files, $thisfile);
        my @thisname = split(/\//, $thisfile);
    	$formatted_breadthfiles = $formatted_breadthfiles . " {$thisname[-1]} ";
    }
}

sub breadthExportList{
    my $exportfile = Tkx::tk___getSaveFile();
    open(EXPORT, ">$exportfile");
    for(@breadth_files){print EXPORT "$_\n";}
    close EXPORT;
}

sub breadthManual {  ###Makes sure everything is order before running the overlap script
    $fileprefix = $breadth_name_textbox ->get(); #It's an entry widget
    if(!$fileprefix){
        Tkx::tk___messageBox(-message=>"You need to name this analysis, so that output files can be generated.");
    }
    elsif(!@breadth_files){
        Tkx::tk___messageBox(-message=>"You need to pick some files.");
    }
    elsif ($output_directory =~ /^directory not set/i) {
        Tkx::tk___messageBox(-message=>"You need to specify an output directory.");
    }
    else{breadthExecute();}
    Tkx::tk___messageBox(-message=>"Analysis \"$fileprefix\" is finished.");
}

sub breadthExecute{

	#####  PRINT HEADER LINE  #####
	my $outfile = $output_directory . "/" . $fileprefix . "_niche_breadth.csv";
	open(OUTFILE, ">$outfile") || die "\n\nCan't write to $outfile\n\n";
	print OUTFILE "FILE,B1 (inverse concentration),B2 (uncertainty)\n";
	
	for(my $i = 0; $i < @breadth_files; $i++){
		my @shortname = split(/\//, $breadth_files[$i]);
	    print OUTFILE "$shortname[-1],";
	    my $numcells = 0;
	    my $sum = 0;
	    my $B1score = 0;
	    my $B2score = 0;
	    open(TEMP1, $breadth_files[$i]) || die "\n\nCan't open $breadth_files[$i]!!\n\n";
	    my @file1 = <TEMP1>;
	    close TEMP1;
	    print "Calculating niche breadth for $breadth_files[$i]\n";
	        for(my $k = 0; $k < @file1; $k++){   #####  Cycle through lines in file  #####
                #$file1[$k] =~ s/\r/\n/g;
	        if(($file1[$k] =~ /^\s*\d/ ) || ($file1[$k] =~ /^\s*-/)){
	            my @line1 = split(/\s+/, $file1[$k]);
	            for(my $l = 0; $l < @line1; $l++){ ##### Cycle through values in line #####
	                if($line1[$l] ne "-9999"){
	                    $sum += $line1[$l];
	                    $numcells++;
	                }
	            }
	        }
	    }
	    print "Sum over $breadth_files[$i] is $sum\n";
	    for(my $k = 0; $k < @file1; $k++){   #####  Cycle through lines in file  #####
	        if(($file1[$k] =~ /^\s*\d/ ) || ($file1[$k] =~ /^\s*-/)){
	            my @line1 = split(/\s+/, $file1[$k]);
	            for(my $l = 0; $l < @line1; $l++){ ##### Cycle through values in line #####
	                if($line1[$l] ne "-9999"){
                      if($line1[$l] == 0){print "Found zero at line $k column $l\n"}
	                    #if ($line1[$l] > 1){die "\n\nNeed raw suitability scores!\n\n";}
	                    $B1score += ($line1[$l]/$sum)*($line1[$l]/$sum);
	                    $B2score += ($line1[$l]/$sum)*log($line1[$l]/$sum);
	                }
	            }
	        }
	    }
	    $B1score = (1/$B1score - 1)/($numcells - 1);
	    $B2score = 0 - $B2score/log($numcells);
	    print OUTFILE "$B1score,$B2score\n";
	}
	close OUTFILE;
}


##### Functions for use in standardizing ASCII rasters
sub standardizeAddFiles {
    my $addfiles;
    for (@standardize_files){
    	$addfiles = $addfiles . " {$_}";
    }
    my $newfiles = Tkx::tk___getOpenFile(-multiple=>TRUE);
    unless($newfiles =~ /\}\s+\{/ || $newfiles =~ /^\{/){  # All of this shit is just to make sure that file names are parsed consistently.  ARGH TKX. WTF.
    	$newfiles =~ s/\s+/} {/g;
    	$newfiles = "{" . $newfiles . "}";
    }
    $addfiles = $addfiles . " " . $newfiles;
    $addfiles =~ s/^\s+//;
    @standardize_files = ();
    $formatted_standardizefiles = "";
    #Tkx::tk___messageBox(-message=>"$addfiles");
    my @thesefiles = split(/}\s+{/, $addfiles);
    for(@thesefiles){
    	$_ =~ s/\{//;
    	$_ =~ s/\}//;
    	push (@standardize_files, $_);
    	my @thisname = split(/\//, $_);
    	$formatted_standardizefiles = $formatted_standardizefiles . " {$thisname[-1]} ";
    }
}


sub standardizeClearFiles {
    @standardize_files = ();
    $formatted_standardizefiles = "";
}

sub standardizeImportList{
    @standardize_files=();
    $formatted_standardizefiles = "";
    my $importfile = Tkx::tk___getOpenFile();
    open(IMPORT, "$importfile");
    while(<IMPORT>) {
        my $thisfile = $_;
        chomp($thisfile);
        push(@standardize_files, $thisfile);
        my @thisname = split(/\//, $thisfile);
    	$formatted_standardizefiles = $formatted_standardizefiles . " {$thisname[-1]} ";
    }
}

sub standardizeExportList{
    my $exportfile = Tkx::tk___getSaveFile();
    open(EXPORT, ">$exportfile");
    for(@standardize_files){print EXPORT "$_\n";}
    close EXPORT;
}

sub standardizeManual {  ###Makes sure everything is order before running the overlap script
    if(!@standardize_files){
        Tkx::tk___messageBox(-message=>"You need to pick some files.");
    }
    else{standardizeExecute();}
    Tkx::tk___messageBox(-message=>"Standardization is finished.");
}

sub standardizeExecute{
	#####  PRINT HEADER LINE  #####
	
	for(my $i = 0; $i < @standardize_files; $i++){
		my $outfile = $standardize_files[$i];
		$outfile =~ s/\.asc$/_standardized.asc/i;
		open(OUTFILE, ">$outfile");
	  my $sum = 0;
	  open(TEMP1, $standardize_files[$i]) || die "\n\nCan't open $standardize_files[$i]!!\n\n";
	  my @file1 = <TEMP1>;
	  close TEMP1;
	  print "Standardizing $standardize_files[$i]\n";
	  for(my $k = 0; $k < @file1; $k++){   #####  Cycle through lines in file  #####
            #$file1[$k] =~ s/\r/\n/g;
	        if(($file1[$k] =~ /^\s*\d/ ) || ($file1[$k] =~ /^\s*-/)){
	            my @line1 = split(/\s+/, $file1[$k]);
	            for(my $l = 0; $l < @line1; $l++){ ##### Cycle through values in line #####
	                if($line1[$l] ne "-9999"){
	                    $sum += $line1[$l];
	                    $numcells++;
	                }
	            }
	        }
	    }
	    print "Sum over $standardize_files[$i] is $sum\n";
	    for(my $k = 0; $k < @file1; $k++){   #####  Cycle through lines in file  #####
	        if(($file1[$k] =~ /^\s*\d/ ) || ($file1[$k] =~ /^\s*-/)){
              chomp($file1[$k]);
	            my @line1 = split(/\s+/, $file1[$k]);
	            for(my $l = 0; $l < @line1; $l++){ ##### Cycle through values in line #####
	                if($line1[$l] eq "-9999"){
                    print OUTFILE "-9999 ";
	                }
	                else{
                    my $standvalue = $line1[$l]/$sum;
                    print OUTFILE "$standvalue ";
	                }
	            }
	            print OUTFILE "\n";
	        }
	        else{print OUTFILE $file1[$k];}
	    }
	}
	close OUTFILE;
}

##### Functions for use in measuring range overlap
sub rangeOverlapAddFiles {
    my $addfiles;
    for (@range_overlap_files){
    	$addfiles = $addfiles . " {$_}";
    }
    my $newfiles = Tkx::tk___getOpenFile(-multiple=>TRUE);
    unless($newfiles =~ /\}\s+\{/ || $newfiles =~ /^\{/){  # All of this shit is just to make sure that file names are parsed consistently.  ARGH TKX. WTF.
    	$newfiles =~ s/\s+/} {/g;
    	$newfiles = "{" . $newfiles . "}";
    }
    $addfiles = $addfiles . " " . $newfiles;
    $addfiles =~ s/^\s+//;
    @range_overlap_files = ();
    $formatted_range_overlapfiles = "";
    #Tkx::tk___messageBox(-message=>"$addfiles");
    my @thesefiles = split(/}\s+{/, $addfiles);
    for(@thesefiles){
    	$_ =~ s/\{//;
    	$_ =~ s/\}//;
    	push (@range_overlap_files, $_);
    	my @thisname = split(/\//, $_);
    	$formatted_range_overlapfiles = $formatted_range_overlapfiles . " {$thisname[-1]} ";
    }
}


sub rangeOverlapClearFiles {
    @range_overlap_files = ();
    $formatted_range_overlapfiles = "";
}

sub rangeOverlapImportList{
    @range_overlap_files=();
    $formatted_range_overlapfiles = "";
    my $importfile = Tkx::tk___getOpenFile();
    open(IMPORT, "$importfile");
    while(<IMPORT>) {
        my $thisfile = $_;
        chomp($thisfile);
        push(@range_overlap_files, $thisfile);
        my @thisname = split(/\//, $thisfile);
    	$formatted_range_overlapfiles = $formatted_range_overlapfiles . " {$thisname[-1]} ";
    }
}

sub rangeOverlapExportList{
    my $exportfile = Tkx::tk___getSaveFile();
    open(EXPORT, ">$exportfile");
    for(@range_overlap_files){print EXPORT "$_\n";}
    close EXPORT;
}


sub rangeOverlapManual {  ###Makes sure everything is order before running the overlap script
    $fileprefix = $range_overlap_name_textbox ->get(); #It's an entry widget
    if(!$fileprefix){
        Tkx::tk___messageBox(-message=>"You need to name this analysis, so that output files can be generated.");
    }
    elsif(!@range_overlap_files){
        Tkx::tk___messageBox(-message=>"You need to pick some files.");
    }
    elsif ($output_directory =~ /^directory not set/i) {
        Tkx::tk___messageBox(-message=>"You need to specify an output directory.");
    }
    else{rangeOverlapExecute();}
    Tkx::tk___messageBox(-message=>"Analysis \"$fileprefix\" is finished.");
}

sub rangeOverlapExecute{
#This is where the guts of the overlap script are executed
#Wants to see files to compare in array @overlap_files and wants a name in $fileprefix
    #####  PRINT HEADER LINE  #####
    my @shortnames;
    for (@range_overlap_files) {
        my @thisname = split(/\//, $_);
        push (@shortnames, $thisname[-1]);
    }
    my $threshold = $range_overlap_cutoff_textbox->get();
    
    my $outfile = $output_directory . "/". $fileprefix . "_range_overlap.csv";
    open(OUTFILE, ">$outfile") || die "\n\nCan't write to $outfile\n\n";
    print OUTFILE "SPECIES";
    for(my $i = 0; $i < @shortnames; $i++){
        my $thisfile = $shortnames[$i];
        chomp($thisfile);
        print OUTFILE ",$thisfile";
    }
    print OUTFILE "\n";
    
    #print "In rangeOverlapExecute, using $outfile\n";
    for(my $i = 0; $i < @range_overlap_files; $i++){
        print OUTFILE "$shortnames[$i],";
        for(my $j = 0; $j < @range_overlap_files; $j++){
            if($i != $j){
            	open (LOGFILE, ">logfile.txt");
                my $inumcells = 0;
                my $jnumcells = 0;
                my $overlapcells = 0;
                open(TEMP1, $range_overlap_files[$i]) || die "\n\nCan't open $range_overlap_files[$i]!!\n\n";
                open(TEMP2, $range_overlap_files[$j]) || die "\n\nCan't open $range_overlap_files[$j]!!\n\n";
                my @file1 = <TEMP1>;
                my @file2 = <TEMP2>;
                close TEMP1;
                close TEMP2;
                my $overlapscore = 0;
                print "Comparing $range_overlap_files[$i] and $range_overlap_files[$j]\n";
                my $warning = "no";
                for(my $k = 0; $k < @file1; $k++){   #####  Cycle through to get sum for all point probabilities in each file  #####
                	#$file1[$k] =~ s/\r/\n/g;
                	#$file2[$k] =~ s/\r/\n/g;
                    if((($file1[$k] =~ /^\s*\d/ ) || ($file1[$k] =~ /^\s*-/ ) ) && (($file2[$k] =~ /^\s*\d/ )|| ($file2[$k] =~ /^\s*-/ ))){
                        my @line1 = split(/\s+/, $file1[$k]);
                        my @line2 = split(/\s+/, $file2[$k]);
                        for(my $l = 0; $l < @line1; $l++){
                           unless(exists($line2[$l])){print LOGFILE "Problem at $k, $l\n";}
                           if($line1[$l] ne "-9999" && $line2[$l] ne "-9999"){
                                if($line1[$l] >= $threshold){$inumcells++;}
                                if($line2[$l] >= $threshold){$jnumcells++;}
                                if($line1[$l] >= $threshold && $line2[$l] >= $threshold){$overlapcells++;}
                            }
                           
                          
                       }
                   }
                }
                close LOGFILE;
                print "$inumcells\t$jnumcells\t$overlapcells\n\n";
                if($inumcells > $jnumcells){$overlapscore = $overlapcells/$jnumcells;}
                else{$overlapscore = $overlapcells/$inumcells;}
                if($j == (@range_overlap_files-1)){  #####  Last value in line  
                    print OUTFILE "$overlapscore\n";
                }
                else{
                    print OUTFILE "$overlapscore,";
                }
                
            }
            else{
                if($j == (@range_overlap_files-1)){  #####  Last value in line  
                    print OUTFILE "1\n";
                }
                else{
                    print OUTFILE "1,";
                }
            
            }
        }
    }
    close OUTFILE;
}




##### Functions for measuring correlations between ASCII rasters

sub corrAddFiles {
    my $addfiles;
    for (@corr_files){
    	$addfiles = $addfiles . " {$_}";
    }
    my $newfiles = Tkx::tk___getOpenFile(-multiple=>TRUE);
    unless($newfiles =~ /\}\s+\{/ || $newfiles =~ /^\{/){  # All of this shit is just to make sure that file names are parsed consistently.  ARGH TKX. WTF.
    	$newfiles =~ s/\s+/} {/g;
    	$newfiles = "{" . $newfiles . "}";
    }
    $addfiles = $addfiles . " " . $newfiles;
    $addfiles =~ s/^\s+//;
    @corr_files = ();
    $formatted_corrfiles = "";
    #Tkx::tk___messageBox(-message=>"$addfiles");
    my @thesefiles = split(/}\s+{/, $addfiles);
    for(@thesefiles){
    	$_ =~ s/\{//;
    	$_ =~ s/\}//;
    	push (@corr_files, $_);
    	my @thisname = split(/\//, $_);
    	$formatted_corrfiles = $formatted_corrfiles . " {$thisname[-1]} ";
    }
}


sub corrClearFiles {
    @corr_files = ();
    $formatted_corrfiles = "";
}

sub corrImportList{
    @corr_files=();
    $formatted_corrfiles = "";
    my $importfile = Tkx::tk___getOpenFile();
    open(IMPORT, "$importfile");
    while(<IMPORT>) {
        my $thisfile = $_;
        chomp($thisfile);
        push(@corr_files, $thisfile);
        my @thisname = split(/\//, $thisfile);
    	$formatted_corrfiles = $formatted_corrfiles . " {$thisname[-1]} ";
    }
}

sub corrExportList{
    my $exportfile = Tkx::tk___getSaveFile();
    open(EXPORT, ">$exportfile");
    for(@corr_files){print EXPORT "$_\n";}
    close EXPORT;
}


sub corrManual {  ###Makes sure everything is order before running the corr script
    $fileprefix = $corr_name_textbox ->get(); #It's an entry widget
    if(!$fileprefix){
        Tkx::tk___messageBox(-message=>"You need to name this analysis, so that output files can be generated.");
    }
    elsif(!@corr_files){
        Tkx::tk___messageBox(-message=>"You need to pick some files.");
    }
    elsif ($output_directory =~ /^directory not set/i) {
        Tkx::tk___messageBox(-message=>"You need to specify an output directory.");
    }
    else{corrExecute();}
    Tkx::tk___messageBox(-message=>"Analysis \"$fileprefix\" is finished.");
}

sub corrExecute{
#This is where the guts of the correlation script are executed
#Wants to see files to compare in array @corr_files and wants a name in $fileprefix
    #####  PRINT HEADER LINE  #####
    my @shortnames;
    for (@corr_files) {
        my @thisname = split(/\//, $_);
        push (@shortnames, $thisname[-1]);
    }
    
    my $routfile = $output_directory . "/". $fileprefix . "_correlation.csv";
    open(ROUTFILE, ">$routfile") || die "\n\nCan't write to $routfile\n\n";
    print ROUTFILE "SPECIES";
    for(my $i = 0; $i < @shortnames; $i++){
        my $thisfile = $shortnames[$i];
        chomp($thisfile);
        print ROUTFILE ",$thisfile";
    }
    print ROUTFILE "\n";
    
    my $slopefile = $output_directory . "/". $fileprefix . "_slope.csv";
    open(SLOPEFILE, ">$slopefile") || die "\n\nCan't write to $slopefile\n\n";
    print SLOPEFILE "SPECIES";
    for(my $i = 0; $i < @shortnames; $i++){
        my $thisfile = $shortnames[$i];
        chomp($thisfile);
        print SLOPEFILE ",$thisfile";
    }
    print SLOPEFILE "\n";
    
    my $interceptfile = $output_directory . "/". $fileprefix . "_intercept.csv";
    open(INTERCEPTFILE, ">$interceptfile") || die "\n\nCan't write to $interceptfile\n\n";
    print INTERCEPTFILE "SPECIES";
    for(my $i = 0; $i < @shortnames; $i++){
        my $thisfile = $shortnames[$i];
        chomp($thisfile);
        print INTERCEPTFILE ",$thisfile";
    }
    print INTERCEPTFILE "\n";
    
    #print "In corrExecute, using $ioutfile and $doutfile\n";
    for(my $i = 0; $i < @corr_files; $i++){
        print ROUTFILE "$shortnames[$i],";
        print SLOPEFILE "$shortnames[$i],";
        print INTERCEPTFILE "$shortnames[$i],";
        
        for(my $j = 0; $j < @corr_files; $j++){
            if($i < $j){
            	my @results = regression($corr_files[$i], $corr_files[$j]);
            	print "Comparing $corr_files[$i] and $corr_files[$j]\n";
                if($j == (@corr_files-1)){  #####  Last value in line  
                    print ROUTFILE "$results[2]\n";
                    print SLOPEFILE "$results[0]\n";
                    print INTERCEPTFILE "$results[1]\n";
                }
                else{
                    print ROUTFILE "$results[2],";
                    print SLOPEFILE "$results[0],";
                    print INTERCEPTFILE "$results[1],";
                }
                
            }
            else{
                if($j == (@corr_files-1)){  #####  Last value in line  
                    print ROUTFILE "0\n";
                    print SLOPEFILE "0\n";
                    print INTERCEPTFILE "0\n";
                }
                else{
                    print ROUTFILE "0,";
                    print SLOPEFILE "0,";
                    print INTERCEPTFILE "0,";
                }
            
            }
        }
    }
    close ROUTFILE;
    close SLOPEFILE;
    close INTERCEPTFILE;
}

##### Functions for use in measuring niche breadth
sub trimdupesAddFiles {
    my $addfiles;
    for (@trimdupes_files){
    	$addfiles = $addfiles . " {$_}";
    }
    my $newfiles = Tkx::tk___getOpenFile(-multiple=>TRUE);
    unless($newfiles =~ /\}\s+\{/ || $newfiles =~ /^\{/){  # All of this shit is just to make sure that file names are parsed consistently.  ARGH TKX. WTF.
    	$newfiles =~ s/\s+/} {/g;
    	$newfiles = "{" . $newfiles . "}";
    }
    $addfiles = $addfiles . " " . $newfiles;
    $addfiles =~ s/^\s+//;
    @trimdupes_files = ();
    $formatted_trimdupesfiles = "";
    #Tkx::tk___messageBox(-message=>"$addfiles");
    my @thesefiles = split(/}\s+{/, $addfiles);
    for(@thesefiles){
    	$_ =~ s/\{//;
    	$_ =~ s/\}//;
    	push (@trimdupes_files, $_);
    	my @thisname = split(/\//, $_);
    	$formatted_trimdupesfiles = $formatted_trimdupesfiles . " {$thisname[-1]} ";
    }
}


sub trimdupesClearFiles {
    @trimdupes_files = ();
    $formatted_trimdupesfiles = "";
}

sub trimdupesImportList{
    @trimdupes_files=();
    $formatted_trimdupesfiles = "";
    my $importfile = Tkx::tk___getOpenFile();
    open(IMPORT, "$importfile");
    while(<IMPORT>) {
        my $thisfile = $_;
        chomp($thisfile);
        push(@trimdupes_files, $thisfile);
        my @thisname = split(/\//, $thisfile);
    	$formatted_trimdupesfiles = $formatted_trimdupesfiles . " {$thisname[-1]} ";
    }
}

sub trimdupesExportList{
    my $exportfile = Tkx::tk___getSaveFile();
    open(EXPORT, ">$exportfile");
    for(@trimdupes_files){print EXPORT "$_\n";}
    close EXPORT;
}

sub trimdupesManual {  ###Makes sure everything is order before running the overlap script
    if($trimdupes_type eq "grid"){
      $trimdupes_gridfile = Tkx::tk___getOpenFile(-multiple=>FALSE);
    }
    if(!@trimdupes_files){
        Tkx::tk___messageBox(-message=>"You need to pick some files.");
    }
    else{trimdupesExecute();}
}

sub trimdupesExecute{
  my $xll;
  my $yll;
  my $cellsize;
  if($trimdupes_type eq "grid"){ #Doing this first so we only have to go through the grid once
      
      open(GRIDFILE, "$trimdupes_gridfile");

      while(<GRIDFILE>){
        if($_ =~ /xll/ig){
          my @thisline = split(/\s+/, $_);
          #print "$_";
          $xll = $thisline[-1];
        }
        if($_ =~ /yll/ig){
          my @thisline = split(/\s+/, $_);
          #print "$_";
          $yll = $thisline[-1];
        }
        if($_ =~ /cellsize/ig){
          my @thisline = split(/\s+/, $_);
          #print "$_";
          $cellsize = $thisline[-1];
        }
      }
      print "XLL is $xll, YLL is $yll, cell size is $cellsize\n";
  }
  for(@trimdupes_files){
    my $infile = $_;
    if($trimdupes_type eq "exact"){
      my $outfile = $infile;
      $outfile =~ s/.csv$/_trimdupes_exact.csv/i;
      print "Printing points to $outfile\n";
      my $firstline;
      my $linecount = 0;
      open(INFILE, "$infile") || die "Can't open file $infile!\n";
      my %filehash;
      while(<INFILE>){
          chomp($_);
          $_ = $_ . "\n";
          if($_ =~ /species,/i){$firstline = $_;}
          else{
              $filehash{$_}++;
              $linecount++;
          }
      }
      close INFILE;
      open(OUTFILE, ">$outfile") || die "Can't open outfile!";
      if($firstline){print OUTFILE $firstline;}
      my @sorted = sort { $a cmp $b } keys %filehash;
      my $i = 0;
      for($i = 0; $i < @sorted; $i++){
          print OUTFILE $sorted[$i];
      }
      my $eliminated = $linecount - $i;
      print "\n\nFound $linecount lines, eliminated $eliminated duplicates.\n\n";
      close OUTFILE;
      close INFILE;
    }
    else{ #Type is grid
      my $outfile = $infile;
      $outfile =~ s/.csv$/_trimdupes_grid.csv/i;
      print "Printing points to $outfile, using grid $trimdupes_gridfile\n";
      open(OUTFILE, ">$outfile") || die "Can't open $outfile!\n";
      my $latcolumn; #tells the program which column contains lat (assumed to be 1 or 2, the other is assumed to be long)
      open(INFILE, "$infile") || die "Can't open file $infile!\n";
      my @infile = <INFILE>;
      my %filehash;
        #$infile[0] =~ s/\r/\n/g;
        #print  "$infile[0]";
      print OUTFILE "$infile[0]";
      my @thisline = split(/,/, $infile[0]);
      if($thisline[1] =~ /^lat/i || $thisline[1] =~ /^y/i) {$latcolumn = 1;}
      elsif($thisline[2] =~ /^lat/i || $thisline[2] =~ /^y/i) {$latcolumn = 2;}
      print "Lat column is $latcolumn\n";
     
      my $npoints = 0;	
      for (my $j = 1; $j< @infile; $j++){
          #print "$j\n";
        my $thisx;
        my $thisy;
        chomp($infile[$j]);
          #$infile[$j] =~ s/\r/\n/g;
        my @thisline = split(/,/, $infile[$j]);
        if($latcolumn == 1){  
          $thisx = $thisline[2];
          $thisy = $thisline[1];
        }
        else{ #latcolumn is 2
          $thisx = $thisline[1];
          $thisy = $thisline[2];
        }  #
        #print "$thisx,$thisy\n";
        my $row = int(($thisy - $yll)/$cellsize);
        my $col = int(($thisx - $xll)/$cellsize);
          #print "$latcolumn,$thisx,$thisy,$row,$col\n";
        my $thislong = $col * $cellsize + $cellsize/2 + $xll;
        my $thislat = $row * $cellsize + $cellsize/2 + $yll;
        if($latcolumn == 1){  
          my $thispoint = $thisline[0] . "," . $thislat . "," . $thislong . "\n";
          $filehash{$thispoint}++;
        }
        if($latcolumn == 2){  
          my $thispoint = $thisline[0] . "," . $thislong . "," . $thislat . "\n";
          $filehash{$thispoint}++;
        }
        #print TESTLOG "$thisx,$thisy,$layer_value\n";
        
      }
      my @sorted = sort { $a cmp $b } keys %filehash;
      my $i = 0;
      for($i = 0; $i < @sorted; $i++){
          print OUTFILE $sorted[$i];
      }
      close OUTFILE;
      close INFILE;
    }
  }
}



##### Functions for use in the model selection tab
        sub modselExecute{
            {$modselfile = Tkx::tk___getOpenFile();}
            open(MODSELFILE, "$modselfile");
            my $outfile = $modselfile;
            $outfile =~ s/.csv/_model_selection.csv/;
            open(OUTFILE, ">$outfile") || die "Can't write to $outfile!\n";
            print OUTFILE "Points,ASCII file,Log Likelihood,Parameters,Sample Size,AIC score,AICc score,BIC score\n";
            my @filenames = <MODSELFILE>;
            for(my $m = 0; $m < @filenames; $m++){
                chomp($filenames[$m]);
                $filenames[$m] =~ s/\"//ig;
                my @thisline = split(/,/, $filenames[$m]);
                #chomp $thisline[1];
                my $ready_to_go = 1;
                if(!-e $thisline[0]){
                    print "Can't find $thisline[0]!\n";
                    
                }
                if(!-e $thisline[1]){
                    print "Can't find $thisline[1]!\n";
                    $ready_to_go = 0;
                }
                if(!-e $thisline[2]){
                    print "Can't find $thisline[2]!\n";
                    $ready_to_go = 0;
                }
                if($ready_to_go == 1){
                    modselExtractData($thisline[1], $thisline[0], $thisline[2]);
                }
            }
            close OUTFILE;
            print "\nFinished!\n";
        }

        sub modselExtractData{
            my($ascfile, $csvfile, $lambdasfile) = @_;
            print "Extracting data from $ascfile using $csvfile...\n";
            open(THISFILE, "$csvfile");
            my @thisfile = <THISFILE>;
            my $headerline = $thisfile[0];
            close THISFILE;
            my @records = csvToArray($csvfile);
            print OUTFILE "$csvfile,$ascfile";
            my @line = AIC($ascfile, \@records, $lambdasfile, $headerline);
            for(my $i = 0; $i < @line; $i++){
                print OUTFILE ",$line[$i]";
            }
            print OUTFILE "\n";
        }sub AIC{  # Takes a csv file and a set of environmental layers and extracts the values of those layers at the points
            my @data;
            my @points;
            my %fileparams;
            my $AICscore;
            my $AICcscore;
            my $BICscore;
            my $loglikelihood = 0;
            #open (TESTLOG, ">testlog.csv");
            my($datafile, $ref_points, $lambdasfile, $headerline) = @_;
            @points = @{$ref_points};
            open(LAMBDAS, $lambdasfile);
            my $nparams = 0;
            print "Opening lambdas file...\n";
            while(<LAMBDAS>){
                my @thisline = split(/,/, $_);
                my $weight = $thisline[1];
                $weight =~ s/\s+//;
                #print "Weight is $weight, ";
                unless($weight eq "0.0"){
                    $nparams++;
                    #print "Nparams is $nparams";
                }
                #print "\n";
            }
            $nparams = $nparams - 4;
            close LAMBDAS;
            
            my $latcolumn; #tells the program which column contains lat (assumed to be 1 or 2, the other is assumed to be long)
            my @thisline = split(/,/, $headerline);
            if($thisline[1] =~ /^lat/i) {$latcolumn = 1;}
            elsif($thisline[2] =~ /^lat/i) {$latcolumn = 2;}
            
            open (DATAFILE, $datafile)                                    ||die "Couldn't open $datafile!";
            while(<DATAFILE>){
                unless ($_=~ /^\s*[0123456789-]/){ # Distinguishes file parameters from data
                    my @thisline = split(/\s+/, $_);
                    $fileparams{lc($thisline[0])} = $thisline[1]; #Keys are being converted to all lower case!
                }
            }
            close DATAFILE;
            my $xll = $fileparams{xllcorner};
            my $yll = $fileparams{yllcorner};
            my $cellsize = $fileparams{cellsize};
            
            open (LAYER, "$datafile");
            my @env_data;
            my $probsum = 0;
            while(<LAYER>){
                if ($_=~ /^\s*[0123456789-]/){ # Distinguishes file parameters from data
                    chomp($_);
                    unshift(@env_data, $_);	#Remember, zero is the bottom left!
                    my @thisline = split(/\s+/, $_);
                    for(my $k = 0; $k < @thisline; $k++){
                        if($thisline[$k] != -9999){$probsum += $thisline[$k];}
                    }
                }
            }
            #print TESTLOG "probsum,$probsum\n";
            close LAYER;
            my $npoints = 0;
            for (my $j = 0; $j< @points; $j++){
                my $thisx;
                my $thisy;
                chomp($points[$j]);
                my @thisline = split(/,/, $points[$j]);
                if($latcolumn == 1){
                    $thisx = $thisline[1];
                    $thisy = $thisline[0];
                }
                else{ #latcolumn is 2
                    $thisx = $thisline[0];
                    $thisy = $thisline[1];
                }  #
                #print "$thisx,$thisy\n";
                my $row = int(($thisy - $yll)/$cellsize);
                my $col = int(($thisx - $xll)/$cellsize);
                #print "$thisx,$thisy,$row,$col\n";
                @thisline = split(/\s+/, $env_data[$row]);
                my $layer_value = $thisline[$col];
                #print TESTLOG "$thisx,$thisy,$layer_value\n";
                if($layer_value > 0){
                    $loglikelihood = $loglikelihood + log($layer_value/$probsum);
                    $npoints++;
                }
                else{print "Found probability of $layer_value!\n";}
            }	
            if($nparams >= $npoints - 1){
                $AICcscore = "x";
                $AICscore = "x";
                $BICscore = "x";
            }
            else{
                $AICcscore = (2 * $nparams - 2 * $loglikelihood) + (2*($nparams)*($nparams+1)/($npoints - $nparams - 1));
                $AICscore = 2 * $nparams - 2 * $loglikelihood;	
                $BICscore = $nparams*log($npoints) - 2*$loglikelihood;
            }
            print "$nparams\n";
            return ($loglikelihood, $nparams, $npoints, $AICscore, $AICcscore, $BICscore);
            
        }
        




##### Functions for use in the identity tab
sub identityAddFiles {
    my $addfiles;
    for (@identity_files){
    	$addfiles = $addfiles . " {$_}";
    }
    my $newfiles = Tkx::tk___getOpenFile(-multiple=>TRUE);
    unless($newfiles =~ /\}\s+\{/ || $newfiles =~ /^\{/){  # All of this shit is just to make sure that file names are parsed consistently.  ARGH TKX. WTF.
    	$newfiles =~ s/\s+/} {/g;
    	$newfiles = "{" . $newfiles . "}";
    }
    $addfiles = $addfiles . " " . $newfiles;
    $addfiles =~ s/^\s+//;
    @identity_files = ();
    $formatted_identityfiles = "";
    #Tkx::tk___messageBox(-message=>"$addfiles");
    my @thesefiles = split(/}\s+{/, $addfiles);
    for(@thesefiles){
    	$_ =~ s/\{//;
    	$_ =~ s/\}//;
    	push (@identity_files, $_);
    	my @thisname = split(/\//, $_);
    	$formatted_identityfiles = $formatted_identityfiles . " {$thisname[-1]} ";
    }
}

sub identityClearFiles {
    @identity_files = ();
    $formatted_identityfiles = "";
}

sub identityImportList{
    @identity_files=();
    $formatted_identityfiles = "";
    my $importfile = Tkx::tk___getOpenFile();
    open(IMPORT, "$importfile");
    while(<IMPORT>) {
        my $thisfile = $_;
        chomp($thisfile);
        push(@identity_files, $thisfile);
        my @thisname = split(/\//, $thisfile);
    	$formatted_identityfiles = $formatted_identityfiles . " {$thisname[-1]} ";
    }
}

sub identityExportList{
    my $exportfile = Tkx::tk___getSaveFile();
    open(EXPORT, ">$exportfile");
    for(@identity_files){print EXPORT "$_\n";}
    close EXPORT;
}

sub identityExecute{
	my $ready_to_go = 1;
	#if($layers_type eq "CSV file"){  ### This bit checks to see if you've got projection layers when using CSV files for env data
	#	unless(-d $projectiondir){
	#		Tkx::tk___messageBox(-message=>"Need to set a projection directory when using environmental data from a CSV file!");
	#		$ready_to_go = 0;
	#	}
	#}
	if($ready_to_go == 1){	
		my %species;
	    ##### Step through input files to get list of species names, put records into @records #####
	    my @records = ();
	    my $headerline;
	    foreach my $thisfile (@identity_files){
	    	print "$thisfile\n";
	        my $i=0;
	        open(INFILE, "$thisfile") || Tkx::tk___messageBox(-message=>"Can't open $thisfile");
	        while(<INFILE>){
	        	print "$i\n";
	        	print $_;
	            push(@records, $_);
	            if($i == 0){
	                $headerline = $_;
	            }
	            if($i > 0){
	                my @thisline = split(/,/, $_);
	                my $thisspecies = $thisline[0];
	                $species{$thisspecies} += 1;
	            }
	            $i++;
	        }
	        close INFILE;
	        #for(my $i = 0; $i < @records; $i++){
	        #    print "$records[$i]";
	        #}
	    }
	    print "Species\t\t\tRecords\n";
	    foreach my $j( keys(%species)){
	        print"$j\t\t\t$species{$j}\n";
	    }
	    
	    my %trackinghash;  ##### Hash for tracking which pairs have been done and which haven't, since we only need to do the tests in one direction #####
	    my $nreps;
	    if($scripting){$nreps = $scripting_nreps;}
	    else{$nreps = $identity_nreps_textbox -> get();}
	    my $q;
	    my $z;
	    my $optionj = '';
	    if ($options_show_maxent eq "no"){$z = "-z";}
	    else {$z = "";}
	    if($suitability_type =~ /ra/i){
	    	if($options_maxent_version eq "old"){$q = "-Q";}
	    	else{$q = "outputformat=raw";}
	    }
	    if($suitability_type =~ /cu/i){
	    	if($options_maxent_version eq "old"){$q = "-C";}
	    	else{$q = "outputformat=cumulative";}
	    }
	    if($suitability_type =~ /lo/i){$q = "";}
	    if(-d $projectiondir){$optionj = "projectionlayers=\"$projectiondir\"";} #Done this strange way because it's not always going to be set
	    my $bias = '';
	    if(-e $biasfile_path){$bias = "biasfile=\"" . $biasfile_path . "\"";}
	    ##### Step through species array, make files where needed, run analyses #####
	    foreach my $i (keys %species){
	        foreach my $j (keys %species){
	            my $trackcheck1 = $i . $j;
	            my $trackcheck2 = $j . $i;
	            unless(defined($trackinghash{$trackcheck1})||defined($trackinghash{$trackcheck2})){
	                $trackinghash{$trackcheck1} = "YES";    
	                print "$i and $j\n";
	                unless($i eq $j){
	                    my @thesespecies;
	                    for (my $m = 0; $m < @records; $m++){
	                        if (($records[$m] =~ /^\s*$i/)|| ($records[$m] =~ /^\s*$j/)){
	                        	chomp($records[$m]);
	                        	$records[$m] = $records[$m] . "\n";
	                        	push(@thesespecies, $records[$m]);
	                        }
	                    }
	                    
	                    
	                    $fileprefix = $i . "_predicting_" . $j ;
	                    my $speciesname = $output_directory . "/" . $i . "_predicting_" . $j ;
	                    my $repsfile = $speciesname . "_reps.csv";
	                    open(REPSFILE, ">$repsfile");
	                    print REPSFILE $headerline;
	                    ##### This is where the new files will be generated #####
	                    for (my $k = 0; $k < $nreps; $k++){
	                        fisher_yates_shuffle( \@thesespecies);
	                        for (my $n = 0; $n < @thesespecies; $n++){
	                            my @thisline = split(',', $thesespecies[$n]);
	                            my $arraysize = @thesespecies;
	                            if ($n < $species{$i}){
	                                #Tkx::tk___messageBox(-message=>"In species 1, n= $n and array size is $arraysize");
	                                my $iname = $i . "_rep" . $k;
	                                print REPSFILE $iname;
	                                for(my $l = 1; $l < @thisline; $l++){
	                                    print REPSFILE ",$thisline[$l]";
	                                }
	                            }
	                            else{
	                                #Tkx::tk___messageBox(-message=>"In species 2, n= $n and array size is $arraysize");
	                                my $jname = $j . "_rep" . $k;
	                                print REPSFILE "$jname";
	                                for(my $m = 1; $m < @thisline; $m++){
	                                    print REPSFILE ",$thisline[$m]";
	                                }
	                            }
	                        }
	                    }
	                    close REPSFILE;
	
	                    ##### Here we are executing the file
	                    if($identity_runmaxent){
	                    	system("java $memory -jar \"$maxent_path\" -e \"$layers_path\" samplesfile=\"$repsfile\" $optionj $q $z -r -a -b $maxent_beta -o \"$output_directory\" -t categ $pictures $rocplots $responsecurves  $bias $removedupes nowarnings");
	                    	my $maxent_resultsfile = $output_directory . "/" . "maxentResults.csv";
	                    	open(MAXENTRESULTS, "$maxent_resultsfile");
	                    	my %thresholds;
	                    	if($identity_usebinary){
		                    	my @maxent_results = <MAXENTRESULTS>;
		                    	my $minpresence_offset = 0;
		                    	my @results_header = split(/,/, $maxent_results[0]);
		                    	for(my $p = 0; $p < @results_header; $p++){
		                    		if($results_header[$p] =~ /Minimum training presence $suitability_type threshold/){$minpresence_offset = $p;}
		                    	}
		                    	for(my $q = 1; $q < @maxent_results; $q++){
		                    		my @thisline = split(/,/, $maxent_results[$q]);
		                    		$thresholds{$thisline[0]} = $thisline[$minpresence_offset];
		                    		print "$thisline[0] $thisline[$minpresence_offset]\n";
		                    	}
	                    	}
		                    my $identityoutfile = $output_directory . "/IDENTITY_" . $i . "_vs_" . $j . ".csv";
		                    open(IDENTITYOUT, ">$identityoutfile");
		                    if($large_overlap == 0){print IDENTITYOUT "I,Schoener's D,Relative Rank\n";}
		                    else{print IDENTITYOUT "I,Schoener's D\n";}
		                    ##### Here we're doing the overlap script on each pair of ASCII files
		                    for(my $n = 0; $n < $nreps; $n++){
			                   	my $firstasc;
			                   	my $secondasc;
			                   	if($layers_type eq "CSV file"){
				            		my @parsedir = split (/\//, $projectiondir);
				            		my $projname = $parsedir[-1];
				            		$firstasc = $output_directory . "/" . $j . "_rep" .$n . "_$projname" . ".asc";
					            	$secondasc = $output_directory . "/" . $i . "_rep" .$n . "_$projname" . ".asc";
				            	}
				            	else{
				            		$firstasc = $output_directory . "/" . $i . "_rep" .$n . ".asc";
			                   		$secondasc = $output_directory . "/" . $j . "_rep" .$n . ".asc";
				            	}
				            	if($identity_usebinary){
				            		my $firstspecies = $i . "_rep" . $n;
				            		my $secondspecies = $j . "_rep" . $n;
				            		my $firstasc_out = $firstasc;
				            		my $secondasc_out = $secondasc;
				            		$firstasc_out =~ s/.asc//;
				            		$secondasc_out =~ s/.asc//;
				            		$firstasc_out = $firstasc_out . "_threshold.asc";
				            		$secondasc_out = $secondasc_out . "_threshold.asc";
				            		threshold($firstasc, $firstasc_out, $thresholds{$firstspecies});
				            		threshold($secondasc, $secondasc_out, $thresholds{$secondspecies});
				            		$firstasc = $firstasc_out;
				            		$secondasc = $secondasc_out;
				            	}
			                   	@overlap_files = ();
			                   	push(@overlap_files, $firstasc);
			                   	push(@overlap_files, $secondasc);
			                   	print "sending  @overlap_files";
			                   	overlapExecute;
				                my $ifile = $speciesname . "_I_output.csv";
				                my $dfile = $speciesname . "_D_output.csv";
				                my $relrankfile;
				                if($large_overlap == 0){$relrankfile = $speciesname . "_relrank_output.csv";}
				                #print "$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
				                #open(SYMFILE, "$symfile");
				                
				              
				                open(IFILE, "$ifile");
				                my @thisarray = <IFILE>;
				                my @thisline = split(/,/, $thisarray[1]);
				                chomp($thisline[2]);
				                print IDENTITYOUT "$thisline[2],";
				                close IFILE;
				                open(DFILE, "$dfile");
				                @thisarray = <DFILE>;
				                @thisline = split(/,/, $thisarray[1]);
				                chomp($thisline[2]);
				                print IDENTITYOUT "$thisline[2],";
				                close DFILE;
				                if($large_overlap == 0){
									open(RELRANKFILE, "$relrankfile");
									@thisarray = <RELRANKFILE>;
									@thisline = split(/,/, $thisarray[1]);
									chomp($thisline[2]);
									print IDENTITYOUT "$thisline[2]\n";
									close RELRANKFILE;
				                }
				                unless($identity_keepreps){
						            $ifile =~ tr/\//\\/;
						            $dfile =~ tr/\//\\/;
						            $relrankfile =~ tr/\//\\/;
						        #    print "\n\n$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
						            unlink("$ifile");
						            unlink("$dfile");
						            if($large_overlap == 0){unlink("$relrankfile");}
						            unlink("$secondasc");
						            $secondasc =~ s/\.asc/\.html/;
						            unlink("$secondasc");
						            $secondasc =~ s/\.html/\.lambdas/;
						            unlink("$secondasc");
						            $secondasc =~ s/\.lambdas/_omission\.csv/;
						            unlink("$secondasc");
						            $secondasc =~ s/_omission\.csv/_samplePredictions\.csv/;
						            unlink("$secondasc");
						            unlink("$firstasc");
						        	$firstasc =~ s/\.asc/\.html/;
							        unlink("$firstasc");
							        $firstasc =~ s/\.html/\.lambdas/;
							        unlink("$firstasc");
							        $firstasc =~ s/\.lambdas/_omission\.csv/;
							        unlink("$firstasc");
							        $firstasc =~ s/_omission\.csv/_samplePredictions\.csv/;
							        unlink("$firstasc");
						        }
		                }
		                  close IDENTITYOUT;
			                open(TEMPIDENTITY, "$identityoutfile");
			                my @results = <TEMPIDENTITY>;
			                close TEMPIDENTITY;
			                my @sortedI = ();
			                my @sortedD = ();
			                my @sortedRELRANK;
			                if($large_overlap == 0){@sortedRELRANK = ();}
			                $identityoutfile =~ s/.csv/_sorted.csv/;
			                open(SORTEDIDENTITY, ">$identityoutfile");
			                if($large_overlap == 0){print SORTEDIDENTITY "I,D,Relative Rank\n";}
			                else{print SORTEDIDENTITY "I,D\n";}
			                for(my $i = 1; $i < @results; $i++){
			                    my @thisline = split(/,/, $results[$i]);
			                    push(@sortedI, $thisline[0]);
			                    push(@sortedD, $thisline[1]);
			                    if($large_overlap == 0){push(@sortedRELRANK, $thisline[2]);}
			                    @sortedI = sort {$a <=> $b} (@sortedI);
			                    @sortedD = sort {$a <=> $b} (@sortedD);
			                    if($large_overlap == 0){@sortedRELRANK = sort {$a <=> $b} (@sortedRELRANK);}
			                }
			                for(my $j = 0; $j < @results; $j++){
			                    if($sortedI[$j] && $large_overlap == 0){print SORTEDIDENTITY "$sortedI[$j],$sortedD[$j],$sortedRELRANK[$j]\n";}
			                    elsif ($sortedI[$j]){print SORTEDIDENTITY "$sortedI[$j],$sortedD[$j]\n";}
			                    ### ^^ Had to add an if statement because it was going over for some odd reason.
			                }
			                @sortedI = ();
			                @sortedD = ();
			                if($large_overlap == 0){@sortedRELRANK = ();}
			                @results = ();
			                close SORTEDIDENTITY;
		                }#Unless I'm mistaken, this is the end of the operation for each species pair
					}
		        }
		    }
	    }
	    unless($scripting){Tkx::tk___messageBox(-message=>"Identity tests are finished.");}
	}
	@overlap_files = ();
}

##### Functions for use in the background tab
sub backgroundAddSamples {
    $samplesfile = Tkx::tk___getOpenFile();
}

sub backgroundAddBackground{
	$backgroundfile = Tkx::tk___getOpenFile();
}

sub backgroundAddAnalysis{
	#This will put each analysis into an hash with samplesfile, backgroundfile, nbackpoints, and nreps
	#Each of these hashes will then be pushed into @background_analyses
	my $nreps = $background_nreps_textbox -> get();
	my $nbackpoints = $background_nsamples_textbox -> get();
	my %thisanalysis;
	$thisanalysis{'samples'} = $samplesfile;
	$thisanalysis{'background'} = $backgroundfile;
	$thisanalysis{'nback'} = $nbackpoints;
	$thisanalysis{'nreps'} = $nreps;
	$thisanalysis{'projectiondir'} = $projectiondir;
	push(@background_analyses, \%thisanalysis);
	
	#Tkx::tk___messageBox(-message=>"$samplesfile\n$backgroundfile\n$nbackpoints\n$nreps");
	
	backgroundUpdateAnalyses();
}

sub backgroundUpdateAnalyses{
	$formatted_backgroundfiles = "";
    for (my $i = 0; $i < @background_analyses; $i++) {
        my $thisref = $background_analyses[$i];
        my %thisanalysis = %$thisref;
        #print %thisanalysis;
        my @shortbackground = split(/\//, $thisanalysis{'background'});  #convert background file path to just a filename
        my @shortsamples = split(/\//, $thisanalysis{'samples'});  #ditto for samples file
        my $thissentence = " {Comparing samples from " . $shortsamples[-1] . " to " . $thisanalysis{'nback'} . " points from " . $shortbackground[-1] . ", " . $thisanalysis{'nreps'} . " replicates.} "; 
        $formatted_backgroundfiles = $formatted_backgroundfiles . $thissentence;
        #print $formatted_backgroundfiles;
    }
}

sub backgroundClearFiles{
	@background_analyses = ();
	$formatted_backgroundfiles = "";
}

sub backgroundExecute{
	my $ready_to_go = 1;
	if($layers_type eq "CSV file"){  ### This bit checks to see if you've got projection layers when using CSV files for env data
		unless(-d $projectiondir){
			Tkx::tk___messageBox(-message=>"Need to set a projection directory when using environmental data from a CSV file!");
			$ready_to_go = 0;
		}
	}
	if($ready_to_go == 1){
		print "Executing background test...\n";	
		for(my $i = 0; $i < @background_analyses; $i++){
			my %species;
			my $thisref = $background_analyses[$i];
	        my %thisanalysis = %$thisref;
	        #thisanalysis has keys "samples", "background", "nback", and "nreps"
	        #print "$thisanalysis{'samples'}, $thisanalysis{'background'}, $thisanalysis{'nback'}, $thisanalysis{'nreps'}\n";
	        my @backgroundpoints = ();
	        if($thisanalysis{'background'} =~ /asc$/i){@backgroundpoints = maskToPoints($thisanalysis{'background'});}  #Converts .asc mask file to array of points
	        else{@backgroundpoints = csvToArray($thisanalysis{'background'});}
	        my @records = ();
		    my $headerline;
		    my $latcolumn;
	        my $i=0;
			
	        open(INFILE, "$thisanalysis{'samples'}") || Tkx::tk___messageBox(-message=>"Can't open $thisanalysis{'samples'}");
	        while(<INFILE>){
	        	print $_;
	            push(@records, $_);
	            if($i == 0){
	                $headerline = $_;
	            }
	            if($i > 0){
	                my @thisline = split(/,/, $_);
	                my $thisspecies = $thisline[0];
	                $species{$thisspecies} += 1;
	            }
	            $i++;
	        }
	        close INFILE;
	        print "Species\t\t\tRecords\n";
	    	foreach my $j( keys(%species)){
	        	print"$j\t\t\t$species{$j}\n";
	    	}
	    	my @thisheaderline = split(/,/, $headerline);
        if($thisheaderline[1] =~ /^lat/i || $thisheaderline[1] =~ /^y/i) {$latcolumn = 1;}
        elsif($thisheaderline[2] =~ /^lat/i || $thisheaderline[2] =~ /^y/i) {$latcolumn = 2;}
        if($latcolumn == 1 && $thisanalysis{'background'} =~ /asc$/i){ #reversing lat and lon
          for(my $w = 0; $w < @backgroundpoints; $w++){
            my @thispoint = split(/,/, $backgroundpoints[$w]);
            $backgroundpoints[$w] = $thispoint[1] . "," . $thispoint[0];
          }
        } 
	    	my $nreps = $thisanalysis{'nreps'};
		    my $q;
		    my $z;
		    my $optionj ='';
		    if ($options_show_maxent eq "no"){$z = "-z";}
		    else {$z = "";}
		    if($suitability_type =~ /ra/i){
		    	if($options_maxent_version eq "old"){$q = "-Q";}
		    	else{$q = "outputformat=raw";}
		    }
		    if($suitability_type =~ /cu/i){
		    	if($options_maxent_version eq "old"){$q = "-C";}
		    	else{$q = "outputformat=cumulative";}
		    }
		    if($suitability_type =~ /lo/i){$q = "";}
		    if(-d $projectiondir){$optionj = "projectionlayers=\"$projectiondir\"";} #Done this strange way because it's not always going to be set
		    my $bias = '';
        if(-e $biasfile_path){$bias = "biasfile=\"" . $biasfile_path . "\"";}
		    #Tkx::tk___messageBox(-message=>"$optionj");
		    
		    ##### Step through species array, make files where needed, run analyses #####
		    foreach my $i (keys %species){
		    	my @thisspecies;
		    	my $speciesout = $i . ".csv";
		    	open(SPECIESOUT, ">$speciesout");
		    	print SPECIESOUT $headerline;
	            for (my $m = 0; $m < @records; $m++){
	            	if ($records[$m] =~ /^\s*$i/){
	            		chomp($records[$m]);
	            		$records[$m] = $records[$m] . "\n";
	            		print SPECIESOUT $records[$m];
	            	}
	            }
	            if($background_runmaxent){
	            	system("java $memory -jar \"$maxent_path\" -e \"$layers_path\" samplesfile=\"$speciesout\" $optionj $q $z -r -a -b $maxent_beta -o \"$output_directory\" -t  categ $pictures $rocplots $responsecurves $bias $removedupes  nowarnings");
		    		my %thresholds;
		    		if($background_usebinary){
                    	my $maxent_resultsfile = $output_directory . "/" . "maxentResults.csv";
	                    open(MAXENTRESULTS, "$maxent_resultsfile");
	                   	my @maxent_results = <MAXENTRESULTS>;
	                   	my $minpresence_offset = 0;
	                   	my @results_header = split(/,/, $maxent_results[0]);
	                   	for(my $p = 0; $p < @results_header; $p++){
	                   		if($results_header[$p] =~ /Minimum training presence $suitability_type threshold/){$minpresence_offset = $p;}
	                   	}
	                   	for(my $q = 1; $q < @maxent_results; $q++){
	                   		my @thisline = split(/,/, $maxent_results[$q]);
	                   		$thresholds{$thisline[0]} = $thisline[$minpresence_offset];
	                   		print "$thisline[0] $thisline[$minpresence_offset]\n";
	                   	}
                    }
		            my @thisname = split(/\//, $thisanalysis{'background'});
		            my @splitname = split(/\./, $thisname[-1]);
		            my $backgroundprefix = $splitname[0];
		            my $backgroundoutfile = $output_directory . "/BACKGROUND_" . $i . "_vs_" . $backgroundprefix . ".csv";
		            open(BACKGROUNDOUT, ">$backgroundoutfile")|| die "Can't open $backgroundoutfile for writing!\n";
		            print BACKGROUNDOUT "I,Schoener's D\n";
		            $fileprefix = $i . "_versus_" . $backgroundprefix ;
		            my $repsfile = $output_directory . "/" . $fileprefix . "_reps.csv";
		            open(REPSFILE, ">$repsfile") || die "Can't open $repsfile for writing!\n";
		            print REPSFILE $headerline;
		            ##### This is where the new files will be generated #####
		            
		            for (my $k = 0; $k < $nreps; $k++){
						fisher_yates_shuffle( \@backgroundpoints);
		                for (my $n = 0; $n < $thisanalysis{'nback'}; $n++){
		                	my @thisline = split(',', $backgroundpoints[$n]);
		                   	my $iname = $i . "_rep" . $k;
		                    print REPSFILE $iname;
		                    for(my $l = 0; $l < @thisline; $l++){
		                    	print REPSFILE ",$thisline[$l]";
		                    }
		                    print REPSFILE "\n";
		   				}
			    	}
		            close REPSFILE;
		            ##### Here we are executing the file
		            
		            system("java $memory -jar \"$maxent_path\" -e \"$layers_path\" samplesfile=\"$repsfile\" $optionj $q $z -r -a -b $maxent_beta -o \"$output_directory\" -t categ $pictures $rocplots $responsecurves $bias $removedupes  nowarnings");
		            
			    	my $firstasc;
					##### Here we're doing the overlap script on each pair of ASCII files
					
                    if($background_usebinary){
                    	my $maxent_resultsfile = $output_directory . "/" . "maxentResults.csv";
	                    open(MAXENTRESULTS, "$maxent_resultsfile");
	                   	my @maxent_results = <MAXENTRESULTS>;
	                   	my $minpresence_offset = 0;
	                   	my @results_header = split(/,/, $maxent_results[0]);
	                   	for(my $p = 0; $p < @results_header; $p++){
	                   		if($results_header[$p] =~ /Minimum training presence $suitability_type threshold/){$minpresence_offset = $p;}
	                   	}
	                   	for(my $q = 1; $q < @maxent_results; $q++){
	                   		my @thisline = split(/,/, $maxent_results[$q]);
	                   		$thresholds{$thisline[0]} = $thisline[$minpresence_offset];
	                   		print "$thisline[0] $thisline[$minpresence_offset]\n";
	                   	}
                    }
		            for(my $n = 0; $n < $nreps; $n++){
		            	
		            	my $secondasc;
		            	if($layers_type eq "CSV file"){
		            		my @parsedir = split (/\//, $projectiondir);
		            		my $projname = $parsedir[-1];
		            		$firstasc = $output_directory . "/" . $i . "_$projname" . ".asc";
			            	$secondasc = $output_directory . "/" . $i . "_rep" .$n . "_$projname" . ".asc";
		            	}
		            	else{
		            		$firstasc = $output_directory . "/" . $i . ".asc";
			            	$secondasc = $output_directory . "/" . $i . "_rep" .$n . ".asc";	
		            	}
						if($background_usebinary){
				           	my $firstspecies = $i;
				           	my $secondspecies = $i . "_rep" . $n;
				           	my $firstasc_out = $firstasc;
				           	my $secondasc_out = $secondasc;
				           	$firstasc_out =~ s/.asc//;
				           	$secondasc_out =~ s/.asc//;
				           	$firstasc_out = $firstasc_out . "_threshold.asc";
				           	$secondasc_out = $secondasc_out . "_threshold.asc";
				           	print"$secondspecies, $thresholds{$secondspecies}\n!!!";
				           	threshold($firstasc, $firstasc_out, $thresholds{$firstspecies});
				           	threshold($secondasc, $secondasc_out, $thresholds{$secondspecies});
				           	$firstasc = $firstasc_out;
				           	$secondasc = $secondasc_out;
				        }
			            @overlap_files = ();
			            push(@overlap_files, $firstasc);
			            push(@overlap_files, $secondasc);
			            print "sending  @overlap_files\n";
			            overlapExecute;
				        my $ifile = $output_directory . "/" . $fileprefix . "_I_output.csv";
				        my $dfile = $output_directory . "/" . $fileprefix . "_D_output.csv";
				        my $relrankfile = $output_directory . "/" . $fileprefix . "_relrank_output.csv";
				        #print "$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
				        open(IFILE, "$ifile");
				        my @thisarray = <IFILE>;
				        my @thisline = split(/,/, $thisarray[1]);
				        chomp($thisline[2]);
				        print BACKGROUNDOUT "$thisline[2],";
				        close IFILE;
				        open(DFILE, "$dfile");
				        @thisarray = <DFILE>;
				        @thisline = split(/,/, $thisarray[1]);
				        chomp($thisline[2]);
				        print BACKGROUNDOUT "$thisline[2],";
				        close DFILE;
				        open(RELRANKFILE, "$relrankfile");
				        @thisarray = <RELRANKFILE>;
				        @thisline = split(/,/, $thisarray[1]);
				        chomp($thisline[2]);
				        print BACKGROUNDOUT "$thisline[2]\n";
				        close RELRANKFILE;
				        unless($background_keepreps){
				            $ifile =~ tr/\//\\/;
				            $dfile =~ tr/\//\\/;
				        #    print "\n\n$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
				            unlink("$ifile");
				            unlink("$dfile");
				            unlink("$secondasc");
				            $secondasc =~ s/\.asc/\.html/;
				            unlink("$secondasc");
				            $secondasc =~ s/\.html/\.lambdas/;
				            unlink("$secondasc");
				            $secondasc =~ s/\.lambdas/_omission\.csv/;
				            unlink("$secondasc");
				            $secondasc =~ s/_omission\.csv/_samplePredictions\.csv/;
				            unlink("$secondasc");
				        }
		            }
		            close BACKGROUNDOUT;
			        open(TEMPBACKGROUND, "$backgroundoutfile");
			        my @results = <TEMPBACKGROUND>;
			        close TEMPBACKGROUND;
			        my @sortedI;
			        my @sortedD;
			        my @sortedRELRANK;
			        open(SORTEDBACKGROUND, ">$backgroundoutfile");
			        print SORTEDBACKGROUND "I,D,Relative Rank\n";
			        for(my $i = 1; $i < @results; $i++){
			            my @thisline = split(/,/, $results[$i]);
			            push(@sortedI, $thisline[0]);
			            push(@sortedD, $thisline[1]);
			            push(@sortedRELRANK, $thisline[2]);
			            @sortedI = sort {$a <=> $b} (@sortedI);
			            @sortedD = sort {$a <=> $b} (@sortedD);
			            @sortedRELRANK = sort {$a <=> $b} (@sortedRELRANK);
			        }
			        for(my $j = 0; $j < @results; $j++){
			            if($sortedI[$j]){print SORTEDBACKGROUND "$sortedI[$j],$sortedD[$j],$sortedRELRANK[$j]\n";}
			            ### ^^ Had to add an if statement because it was going over for some odd reason.
			        }
			        unless($background_keepreps){#change back to "unless background_keepreps"
			        	unlink("$firstasc");
			        	$firstasc =~ s/\.asc/\.html/;
				        unlink("$firstasc");
				        $firstasc =~ s/\.html/\.lambdas/;
				        unlink("$firstasc");
				        $firstasc =~ s/\.lambdas/_omission\.csv/;
				        unlink("$firstasc");
				        $firstasc =~ s/_omission\.csv/_samplePredictions\.csv/;
				        unlink("$firstasc");
			        }
			        close SORTEDBACKGROUND;
			        @sortedI = ();
			        @sortedD = ();
			        @sortedRELRANK = ();
			        @results = ();
		        }#Unless I'm mistaken, this is the end of the operation for each species pair
			}
		}
		Tkx::tk___messageBox(-message=>"Background tests are finished.");
	}
	@overlap_files = ();
}


#####Functions for use in the Jackknife tab
sub jackbootAddFiles {
    my $addfiles;
    for (@jackboot_files){
    	$addfiles = $addfiles . " {$_}";
    }
    my $newfiles = Tkx::tk___getOpenFile(-multiple=>TRUE);
    unless($newfiles =~ /\}\s+\{/ || $newfiles =~ /^\{/){  # All of this shit is just to make sure that file names are parsed consistently.  ARGH TKX. WTF.
    	$newfiles =~ s/\s+/} {/g;
    	$newfiles = "{" . $newfiles . "}";
    }
    $addfiles = $addfiles . " " . $newfiles;
    $addfiles =~ s/^\s+//;
    @jackboot_files = ();
    $formatted_jackbootfiles = "";
    #Tkx::tk___messageBox(-message=>"$addfiles");
    my @thesefiles = split(/}\s+{/, $addfiles);
    for(@thesefiles){
    	$_ =~ s/\{//;
    	$_ =~ s/\}//;
    	push (@jackboot_files, $_);
    	my @thisname = split(/\//, $_);
    	$formatted_jackbootfiles = $formatted_jackbootfiles . " {$thisname[-1]} ";
    }
}


sub jackbootClearFiles {
    @jackboot_files = ();
    $formatted_jackbootfiles = '';
}

sub jackbootImportList{
    @jackboot_files=();
    $formatted_jackbootfiles = "";
    my $importfile = Tkx::tk___getOpenFile();
    open(IMPORT, "$importfile");
    while(<IMPORT>) {
        my $thisfile = $_;
        chomp($thisfile);
        push(@jackboot_files, $thisfile);
        my @thisname = split(/\//, $thisfile);
    	$formatted_jackbootfiles = $formatted_jackbootfiles . " {$thisname[-1]} ";
    }
}

sub jackbootExportList{
    my $exportfile = Tkx::tk___getSaveFile();
    open(EXPORT, ">$exportfile");
    for(@jackboot_files){print EXPORT "$_\n";}
    close EXPORT;
}

sub jackbootExecute{
	my $nreps; 
	unless($jackboot_type eq 'Delete one jackknife (deterministic)'){$nreps = $jackboot_nreps_textbox -> get();}
	my $jackprop;
	unless($jackboot_type eq 'Nonparametric bootstrap' || $jackboot_type eq 'Delete one jackknife (deterministic)') {$jackprop = $jackboot_d_textbox -> get();}
	#Tkx::tk___messageBox(-message=>"Doing $nreps reps with $jackprop jackknife proportion.");
	##### Step through input files to get list of species names, put records into @records #####
    my @records = ();
    my %species = ();
    my $headerline;
    my $varmultiplier;
    foreach my $thisfile (@jackboot_files){
        my $i=0;
        open(INFILE, "$thisfile") || Tkx::tk___messageBox(-message=>"Can't open $thisfile");
        while(<INFILE>){
            push(@records, $_);
            if($i == 0){
                $headerline = $_;
            }
            if($i > 0){
                my @thisline = split(/,/, $_);
                my $thisspecies = $thisline[0];
                $species{$thisspecies} += 1;
            }
            $i++;
        }
        close INFILE;
        #for(my $i = 0; $i < @records; $i++){
        #    print "$records[$i]";
        #}
    }
    print "Species\t\t\tRecords\n";
    foreach my $j( keys(%species)){
        print"$j\t\t\t$species{$j}\n";
    }
    my $q;
    my $z;
    if ($options_show_maxent eq "no"){$z = "-z";}
    else {$z = "";}
    if($suitability_type =~ /ra/i){
    	if($options_maxent_version eq "old"){$q = "-Q";}
    	else{$q = "outputformat=raw";}
    }
    if($suitability_type =~ /cu/i){
    	if($options_maxent_version eq "old"){$q = "-C";}
    	else{$q = "outputformat=cumulative";}
    }
    if($suitability_type =~ /lo/i){$q = "";}
    my $bias = '';
	  if(-e $biasfile_path){$bias = "biasfile=\"" . $biasfile_path . "\"";}
    ##### Step through species array, make files where needed, run analyses #####
    foreach my $i (keys %species){
    	my @thisspecies;
        for (my $m = 1; $m < @records; $m++){
        	if ($records[$m] =~ /^\s*$i/){push(@thisspecies, $records[$m]);}
        }
        my $repsfile;
        my $leftoverfile;
        if($jackboot_type eq "Nonparametric bootstrap"){
        	$repsfile = $output_directory . "/" . $i . "_bootstrap_reps.csv" ;
        }
        else{
        	$repsfile = $output_directory . "/" . $i . "_jackknife_reps.csv" ;
        	$leftoverfile = $output_directory . "/" . $i . "_jackknife_leftovers.csv" ;
        }
        open(REPSFILE, ">$repsfile");
        
        print REPSFILE $headerline;
        unless($jackboot_type eq "Nonparametric bootstrap"){
        	open(LEFTOVERFILE, ">$leftoverfile");
        	print LEFTOVERFILE $headerline;
        }
        
        
        #preparing pseudoreps
        if($jackboot_type eq "Delete one jackknife (random)"){
	        for (my $k = 0; $k < $nreps; $k++){
	        	fisher_yates_shuffle( \@thisspecies);
	            for (my $n = 0; $n < @thisspecies; $n++){
	            	my @thisline = split(',', $thisspecies[$n]);
	                my $arraysize = @thisspecies;
	                $jacknum = 2;
	                $varmultiplier = $arraysize-1;
	                if ($n <= ($arraysize - $jacknum)){
	                	#Tkx::tk___messageBox(-message=>"In species 1, n= $n and array size is $arraysize");
	                    my $iname = $i . "_rep" . $k;
	                    print REPSFILE $iname;
	                    for(my $l = 1; $l < @thisline; $l++){
	                    	print REPSFILE ",$thisline[$l]";
	                	}
	         	    }
	         	    else{
	                	#Tkx::tk___messageBox(-message=>"In species 1, n= $n and array size is $arraysize");
	                    my $iname = $i . "_rep" . $k;
	                    print LEFTOVERFILE $iname;
	                    for(my $l = 1; $l < @thisline; $l++){
	                    	print LEFTOVERFILE ",$thisline[$l]";
	                	}
	         	    }
	            }
	        }
	        close REPSFILE;
	        close LEFTOVERFILE;	
		}
		elsif($jackboot_type eq "Delete one jackknife (deterministic)"){ #Each rep missing one point, one data set per point
		    for (my $k = 0; $k < @thisspecies; $k++){
	            for (my $n = 0; $n < @thisspecies; $n++){
	            	my @thisline = split(',', $thisspecies[$n]);
	                my $arraysize = @thisspecies;
	                $nreps = $arraysize;
	                $jacknum = 2;
	                $varmultiplier = $arraysize-1;
	                if($n==$k){
	                	#Tkx::tk___messageBox(-message=>"In species 1, n= $n and array size is $arraysize");
	                    my $iname = $i . "_rep" . $k;
	                    print LEFTOVERFILE $iname;
	                    for(my $l = 1; $l < @thisline; $l++){
	                    	print LEFTOVERFILE ",$thisline[$l]";
	                	}
	         	    }
	                else{
	                	#Tkx::tk___messageBox(-message=>"In species 1, n= $n and array size is $arraysize");
	                    my $iname = $i . "_rep" . $k;
	                    print REPSFILE $iname;
	                    for(my $l = 1; $l < @thisline; $l++){
	                    	print REPSFILE ",$thisline[$l]";
	                	}
	         	    }

	            }
	        }
	        close REPSFILE;
	        close LEFTOVERFILE;	
	
		}
		elsif($jackboot_type eq "Delete d jackknife"){
	        for (my $k = 0; $k < $nreps; $k++){
	        	fisher_yates_shuffle( \@thisspecies);
	            for (my $n = 0; $n < @thisspecies; $n++){
	            	my @thisline = split(',', $thisspecies[$n]);
	                my $arraysize = @thisspecies;
	                if($jackprop < 1){ #Number represents proportion of records to delete
	                	$jacknum = ($jackprop * $arraysize) + 1;
	                	$varmultiplier = 1/$jackprop;
	                }
	                elsif($jackprop > 1){ #Number represents the number of records to delete
	                	$jacknum = $jackprop + 1;
	                	$varmultiplier = $arraysize/($jacknum-1);
	                }
	                else{
	                	die "\n\nJackknife proportion $jackprop not understood.\n\n";
	                }
	                if ($n <= ($arraysize - $jacknum)){
	                	#Tkx::tk___messageBox(-message=>"In species 1, n= $n and array size is $arraysize");
	                    my $iname = $i . "_rep" . $k;
	                    print REPSFILE $iname;
	                    for(my $l = 1; $l < @thisline; $l++){
	                    	print REPSFILE ",$thisline[$l]";
	                	}
	         	    }
	         	    else{
	                	#Tkx::tk___messageBox(-message=>"In species 1, n= $n and array size is $arraysize");
	                    my $iname = $i . "_rep" . $k;
	                    print LEFTOVERFILE $iname;
	                    for(my $l = 1; $l < @thisline; $l++){
	                    	print LEFTOVERFILE ",$thisline[$l]";
	                	}
	         	    }
	            }
	        }
	        close REPSFILE;
	        close LEFTOVERFILE;	
		}
		elsif($jackboot_type eq "Retain X jackknife"){
	        for (my $k = 0; $k < $nreps; $k++){
	        	fisher_yates_shuffle( \@thisspecies);
	        	my $arraysize = @thisspecies;
	        	$varmultiplier = $arraysize/($arraysize-$jackprop);
	            for (my $n = 0; $n < @thisspecies; $n++){
	            	my @thisline = split(',', $thisspecies[$n]);
	                if ($n < $jackprop){
	                	#Tkx::tk___messageBox(-message=>"In species 1, n= $n and array size is $arraysize");
	                    my $iname = $i . "_rep" . $k;
	                    print REPSFILE $iname;
	                    for(my $l = 1; $l < @thisline; $l++){
	                    	print REPSFILE ",$thisline[$l]";
	                	}
	         	    }
	         	    else{
	                	#Tkx::tk___messageBox(-message=>"In species 1, n= $n and array size is $arraysize");
	                    my $iname = $i . "_rep" . $k;
	                    print LEFTOVERFILE $iname;
	                    for(my $l = 1; $l < @thisline; $l++){
	                    	print LEFTOVERFILE ",$thisline[$l]";
	                	}
	         	    }
	            }
	        }
	        close REPSFILE;
	        close LEFTOVERFILE;	
		}
		elsif($jackboot_type eq "Nonparametric bootstrap"){
        	$varmultiplier = 1;
	        for (my $k = 0; $k < $nreps; $k++){
	            for (my $n = 0; $n < @thisspecies; $n++){
	            	fisher_yates_shuffle( \@thisspecies);
	            	my @thisline = split(',', $thisspecies[1]);
	                my $arraysize = @thisspecies;
                	#Tkx::tk___messageBox(-message=>"In species 1, n= $n and array size is $arraysize");
                    my $iname = $i . "_rep" . $k;
                    print REPSFILE $iname;
                    for(my $l = 1; $l < @thisline; $l++){
                    	print REPSFILE ",$thisline[$l]";
                    }
	            }
	        }
	        close REPSFILE;
		}
        

        
		if($jackboot_runmaxent == 1){
	        ##### Here we are executing the file
	        system("java $memory -jar \"$maxent_path\" -e \"$layers_path\" samplesfile=\"$repsfile\" $q $z -r -a -b $maxent_beta -o \"$output_directory\" -t categ $pictures dontremoveduplicates $rocplots $responsecurves $bias  $removedupes  nowarnings");
	        
	        ##### Calculating mean and variance for suitabilities using Knuth's online algorithm that I jacked from Wikipedia
	        my $n = 0;
	        my @means = ();
	        my @M2 = ();
	        my @header = ();
	        for(my $k = 0; $k < $nreps; $k++){  #### Get means and variances from jackknife data
	        	$n++;
	        	my $ascfile = $output_directory . "/" . $i . "_rep" . $k . ".asc";
	        	#print "$ascfile\n";
	        	open (ASCFILE, "$ascfile");
	        	my $linecounter = 0;
	        	while(<ASCFILE>){  #### Step through ascii file getting value for each grid cell
	        		if(($_ =~ /^\s*\d/) || ($_ =~ /^\s*-/ )){
	        			$linecounter++;
	        			my @thisline = split(/\s+/, $_);
	        			for(my $m = 0; $m < @thisline; $m++){
	        				if($thisline[$m] =~ /^-9999/  ){
	        					$means[$linecounter][$m] = -9999;
	        					$M2[$linecounter][$m] = -9999;
	        				}
	        				else{
	        					my $delta = $thisline[$m] - $means[$linecounter][$m];
	        					$means[$linecounter][$m] = $means[$linecounter][$m] + $delta/$n;
	        					$M2[$linecounter][$m] = $M2[$linecounter][$m] + ($delta * ($thisline[$m] - $means[$linecounter][$m]));
	        				}
	        			}
	        		}
	        		elsif($k == $nreps-1){
	        			push(@header, $_);
	        			#print "$_";
	        		}  
	        	}
	        	close ASCFILE;
	        	unless($jackboot_keepreps){
		        	unlink($ascfile);
		        	my $htmlfile = $output_directory . "/" . $i . "_rep" . $k . ".html";
		        	my $omissionfile = $output_directory . "/" . $i . "_rep" . $k . "_omission.csv";
		        	my $samplepredfile = $output_directory . "/" . $i . "_rep" . $k . "_samplePredictions.csv";
		        	unlink($htmlfile);
		        	unlink($omissionfile);
		        	unlink($samplepredfile);
		        	#print "$ascfile has $linecounter lines of data.\n";
		        	#my $lambdafile = $i . "_rep" . $k . ".lambdas";
	        	}
	        }
	        my $meansfile;
	        my $variancefile;
	        if($jackboot eq "jackknife"){
		        $meansfile = $output_directory . "/" . $i . "_jackknife_mean.asc";
		        $variancefile = $output_directory . "/" . $i . "_jackknife_variance.asc";
	        }
	        else{
	        	$meansfile = $output_directory . "/" . $i . "_bootstrap_mean.asc";
		        $variancefile = $output_directory . "/" . $i . "_bootstrap_variance.asc";
	        }
	        open(MEAN, ">$meansfile") || die "Can't open $meansfile for writing!";
	        open(VARIANCE, ">$variancefile") || die "Can't open $variancefile for writing!";
	        for(my $p = 0; $p < @header; $p++){
	        	print MEAN $header[$p];
	        	print VARIANCE $header[$p];
	        }
	        for(my $r = 0; $r < @means; $r++){
	        	my $arrayref1 = @means[$r];
				my @meansline = @$arrayref1;
				my $arrayref2 = @M2[$r];
				my @M2line = @$arrayref2;
	        	for(my $c = 0; $c < @meansline; $c++){
	        		#print "$c\n";
	        		print MEAN "$meansline[$c] ";
	        		#print "$M2line[$c] ";
	        		if($M2line[$c] =~ /^-9999/){print VARIANCE "-9999 ";}
	        		else{
	        			my $thisvar = $M2line[$c]/$n;
	        			$thisvar *= $varmultiplier;
	        			print VARIANCE "$thisvar ";
	        		}
	        	}
	        	print MEAN "\n";
	        	print VARIANCE "\n";
	        	#print "\n";
	        }
	        close MEAN;
	        close VARIANCE;
	        
	        ##### Now we're going to get all of our lambdas into a .csv file  
	        my %lambdahash;
	        my @lambdafiles = ();
	        my $lambdaoutfile;
	        if($jackboot eq "jackknife"){
		        $lambdaoutfile = $output_directory . "/" . $i . "_jackknife_lambdas.csv";
	        }
	        else{
	        	$lambdaoutfile = $output_directory . "/" . $i . "_bootstrap_lambdas.csv";
	        }
	        open(LAMBDAOUT, ">$lambdaoutfile") || die "\nCan't write to $lambdaoutfile!\n";
	        for(my $k = 0; $k < $nreps; $k++){
	        	my $thislambdafile = $output_directory . "/" . $i . "_rep" . $k .".lambdas";
	        	#print "$thislambdafile\n";
	        	open(THISLAMBDA, "$thislambdafile") || die "Can't open $thislambdafile!";
	        	my @thislambda = <THISLAMBDA>;
	        	for(my $q = 0; $q < @thislambda; $q++){  #Populate %lambdahash with header names
	        		#print "$_";
	        		my @thisline = split(/,/ , $thislambda[$q]);
	        		#print "$thisline[0]\n";
	        		$lambdahash{$thisline[0]} = 0;
	        	}
	        	close THISLAMBDA;
	        	unless($jackboot_keepreps){unlink($thislambdafile);}
	        	push (@lambdafiles, \@thislambda);
	        }
	        
	        foreach my $variable(sort(keys %lambdahash)){  # At this point %lambdahash will have a key for every parameter that appears in any lambdas file
	        	print LAMBDAOUT ",$variable";
	        }
	        print LAMBDAOUT "\n";
	        for(my $q = 0; $q < @lambdafiles; $q ++){
	        	my $shortname = $i . "_rep" . $q;
	        	print LAMBDAOUT "$shortname";
	        	foreach my $variable(sort(keys %lambdahash)){  # Set everything to zero for this file
	        		$lambdahash{$variable} = 0;
	        	}
	        	my $arrayref3 = $lambdafiles[$q];
	        	my @thisrep = @$arrayref3;
	        	for(my $w = 0; $w < @thisrep; $w++){  #Going back over the results of each file
	        		my @thisline = split(/,/ , $thisrep[$w]);  
	        		$thisline[1] =~ s/\s//;
	        		chomp($thisline[1]);
	        		#print "$thisline[0]\t$thisline[1]\n";
	        		$lambdahash{$thisline[0]} = $thisline[1];  #Putting the value for this rep into the hash
	        	}
	        	foreach my $variable(sort(keys %lambdahash)){  # Print values from hash
	        		print LAMBDAOUT ",$lambdahash{$variable}";
	        	}
	        	print LAMBDAOUT "\n";
	        }
	        close LAMBDAOUT;
	        #Move maxentresults.csv to an analysis-specific copy so it won't be overwritten
	        my $oldmaxentresults = $output_directory . "/maxentResults.csv"; 
	        my $newmaxentresults = $output_directory . "/" . $i . "_maxentResults.csv";
	        $oldmaxentresults =~ s/\//\\/g;
	        #print "$oldmaxentresults, $newmaxentresults\n";
	        #system "ren \"$oldmaxentresults\" \"$newmaxentresults\"";
	        rename($oldmaxentresults, $newmaxentresults);
	        #print "ren $oldmaxentresults $newmaxentresults\n";
	        #print "\n\nvariance multiplier is $varmultiplier\n\n"
		}
    }
}

#####Functions for use in the cross-validation tab

sub crossvalidationAddFiles {
    my $addfiles;
    for (@crossvalidation_files){
    	$addfiles = $addfiles . " {$_}";
    }
    my $newfiles = Tkx::tk___getOpenFile(-multiple=>TRUE);
    unless($newfiles =~ /\}\s+\{/ || $newfiles =~ /^\{/){  # All of this shit is just to make sure that file names are parsed consistently.  ARGH TKX. WTF.
    	$newfiles =~ s/\s+/} {/g;
    	$newfiles = "{" . $newfiles . "}";
    }
    $addfiles = $addfiles . " " . $newfiles;
    $addfiles =~ s/^\s+//;
    @crossvalidation_files = ();
    $formatted_crossvalidationfiles = "";
    #Tkx::tk___messageBox(-message=>"$addfiles");
    my @thesefiles = split(/}\s+{/, $addfiles);
    for(@thesefiles){
    	$_ =~ s/\{//;
    	$_ =~ s/\}//;
    	push (@crossvalidation_files, $_);
    	my @thisname = split(/\//, $_);
    	$formatted_crossvalidationfiles = $formatted_crossvalidationfiles . " {$thisname[-1]} ";
    }
}


sub crossvalidationClearFiles {
    @crossvalidation_files = ();
    $formatted_crossvalidationfiles = '';
}

sub crossvalidationImportList{
    @crossvalidation_files=();
    $formatted_crossvalidationfiles = "";
    my $importfile = Tkx::tk___getOpenFile();
    open(IMPORT, "$importfile");
    while(<IMPORT>) {
        my $thisfile = $_;
        chomp($thisfile);
        push(@crossvalidation_files, $thisfile);
        my @thisname = split(/\//, $thisfile);
    	$formatted_crossvalidationfiles = $formatted_crossvalidationfiles . " {$thisname[-1]} ";
    }
}

sub crossvalidationExportList{
    my $exportfile = Tkx::tk___getSaveFile();
    open(EXPORT, ">$exportfile");
    for(@crossvalidation_files){print EXPORT "$_\n";}
    close EXPORT;
}

sub crossvalidationExecute{
	my $ready_to_go = 1;
	my $nreps = $crossvalidation_nreps_textbox -> get();
	if($ready_to_go){
		#print "keepreps is $crossvalidation_keepreps\n";
		for(my $analyses = 0; $analyses < @crossvalidation_files; $analyses++){
			my $q;
		    my $z;
		    my $optionj;
		    if ($options_show_maxent eq "no"){$z = "-z";}
		    else {$z = "";}
		    if($suitability_type =~ /ra/i){
		    	if($options_maxent_version eq "old"){$q = "-Q";}
		    	else{$q = "outputformat=raw";}
		    }
		    if($suitability_type =~ /cu/i){
		    	if($options_maxent_version eq "old"){$q = "-C";}
		    	else{$q = "outputformat=cumulative";}
		    }
		    if($suitability_type =~ /lo/i){$q = "";}
		    if(-d $projectiondir){$optionj = "projectionlayers=\"$projectiondir\"";} #Done this strange way because it's not always going to be set
		    my $bias = '';
        if(-e $biasfile_path){$bias = "biasfile=\"" . $biasfile_path . "\"";}
		    my %species = ();
			my @records = ();
		    my $headerline;
		    my $i=0;
		    open(INFILE, "$crossvalidation_files[$analyses]") || Tkx::tk___messageBox(-message=>"Can't open $crossvalidation_files[$analyses]");
			while(<INFILE>){
				push(@records, $_);
			    if($i == 0){
			    	$headerline = $_;
			    }
			    if($i > 0){
			         my @thisline = split(/,/, $_);
			         my $thisspecies = $thisline[0];
			         $species{$thisspecies} += 1;
			    }
			    $i++;
			}
			close INFILE;
			print "Species\t\t\tRecords\n";
			my @thisname = split(/\//, $crossvalidation_files[$analyses]);
			$fileprefix = $thisname[-1];
			$fileprefix =~ s/.csv//;
			
			$repsfile = $output_directory . "/" . $fileprefix . "_crossvalidation_reps.csv"; #Filename for reps
			if($crossvalidation_breaktype eq  "line"){crossvalidation_line(\@records, \%species, $headerline, $repsfile);}
			elsif($crossvalidation_breaktype eq  "blob"){crossvalidation_blob(\@records, \%species, $headerline, $repsfile);}
			else{Tkx::tk___messageBox(-message=>"Problem: breaktype is $crossvalidation_breaktype!");}
			
			
			if($crossvalidation_runmaxent ==1){
					
				##### At this point there should be a file called temp_crossvalidationer.csv that has reps in it
				system("java $memory -jar \"$maxent_path\" -e \"$layers_path\" samplesfile=\"$repsfile\" $optionj $q $z -r -a -b $maxent_beta -o \"$output_directory\" -t categ $pictures $rocplots $responsecurves $bias $removedupes nowarnings");
			    
				##### Here we're doing the overlap script on the ASCII files
				
			    #Overlaps and cleanup for line/blob
			    my $crossvalidationoutfile = $output_directory . "/CROSSVAL_" . $crossvalidation_breaktype . "_" . $fileprefix . ".csv"; #Filename for final summary
				open(CROSSVALOUT, ">$crossvalidationoutfile")|| die "Can't open $crossvalidationoutfile for writing!\n";
			    print CROSSVALOUT "I,Schoener's D\n";
			    for(my $n = 0; $n < $nreps; $n++){
			    	my $firstasc = $output_directory . "/rep_" .$n . "_species1.asc";
			        my $secondasc = $output_directory . "/rep_" .$n . "_species2.asc";;
			        @overlap_files = ();
				    push(@overlap_files, $firstasc);
				    push(@overlap_files, $secondasc);
				    #print "sending  @overlap_files\n";
				    overlapExecute();
					my $ifile = $output_directory . "/" . $fileprefix . "_I_output.csv";
					my $dfile = $output_directory . "/" . $fileprefix . "_D_output.csv";
					#print "$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
					open(IFILE, "$ifile");
					my @thisarray = <IFILE>;
					my @thisline = split(/,/, $thisarray[1]);
					chomp($thisline[2]);
					print CROSSVALOUT "$thisline[2],";
					close IFILE;
					open(DFILE, "$dfile");
					@thisarray = <DFILE>;
					@thisline = split(/,/, $thisarray[1]);
					chomp($thisline[2]);
					print CROSSVALOUT "$thisline[2]\n";
					close DFILE;
					if($crossvalidation_keepreps == 1){}
					else{
					    $ifile =~ tr/\//\\/;
					    $dfile =~ tr/\//\\/;
					#    print "\n\n$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
					    unlink("$ifile");
					    unlink("$dfile");
					    unlink("$firstasc");
					    unlink("$secondasc");
					    $firstasc =~ s/.asc/.html/;
					    $secondasc =~ s/.asc/.html/;
					    unlink("$firstasc");
					    unlink("$secondasc");
					    $firstasc =~ s/.html/.lambdas/;
					    $secondasc =~ s/.html/.lambdas/;
					    unlink("$firstasc");
					    unlink("$secondasc");
					    $firstasc =~ s/.lambdas/_omission.csv/;
					    $secondasc =~ s/.lambdas/_omission.csv/;
					    unlink("$firstasc");
					    unlink("$secondasc");
					    $firstasc =~ s/_omission.csv/_samplePredictions.csv/;
					    $secondasc =~ s/_omission.csv/_samplePredictions.csv/;
					    unlink("$firstasc");
					    unlink("$secondasc");
					}
			    }
			    close CROSSVALOUT;
				open(TEMPCROSSVAL, "$crossvalidationoutfile");
				my @results = <TEMPCROSSVAL>;
				close TEMPCROSSVAL;
				my @sortedI;
				my @sortedD;
				open(SORTEDCROSSVAL, ">$crossvalidationoutfile");
				print SORTEDCROSSVAL "I,Schoener's D\n";
				for(my $i = 1; $i < @results; $i++){
				    my @thisline = split(/,/, $results[$i]);
				    push(@sortedI, $thisline[0]);
				    push(@sortedD, $thisline[1]);
				    @sortedI = sort {$a <=> $b} (@sortedI);
				    @sortedD = sort {$a <=> $b} (@sortedD);
				 }
				 for(my $j = 0; $j < @results; $j++){
				    if($sortedI[$j]){print SORTEDCROSSVAL "$sortedI[$j],$sortedD[$j]\n";}
				    ### ^^ Had to add an if statement because it was going over for some odd reason.
				 }
				 close SORTEDCROSSVAL;	
				 @sortedI = ();
			   @sortedD = ();
			   @results = ();
			}
		}
	}
}


sub crossvalidation_line{
	my $nreps = $crossvalidation_nreps_textbox -> get();
	my $testprop = $crossvalidation_testprop_textbox ->get();
	my $arrayref = shift;
	my $hashref = shift;
	my @records = @$arrayref;
	my %species = %$hashref;
	$headerline = shift;
	$trainingfilename = shift;
	my $testfilename = $trainingfilename;
	$testfilename =~ s/.csv/_test.csv/;
	open (TRAININGOUTFILE, ">$trainingfilename") || die "Can't open $trainingfilename for writing!";
	print TRAININGOUTFILE $headerline;
	open (TESTOUTFILE, ">$testfilename") || die "Can't open $testfilename for writing!";
	print TESTOUTFILE $headerline;
	foreach $speciesname (keys %species){
		my @thisspecies = ();
		for $thisrecord (@records){
			my @thisline = split (/,/, $thisrecord);
			if ($thisline[0] eq $speciesname){
				push (@thisspecies, $thisrecord);}
		}
		my $failurecount = 0;
		my $successcount = 0;
		for(my $i = 0; $i < $nreps; $i++){
			if($failurecount < 1000){
				my $testing;
				my @intercepts = (); 
				my $angle = rand(90);  #Randomly picking slope and sign
				my $plusminus = rand(2);
				my $slope = (sin($angle)/cos($angle)); 
				if($plusminus <= 1){$slope = 0 - $slope;}
				#print "slope is $slope\n";
				
				for(my $j = 1; $j < @thisspecies; $j++){  #Figuring out what the distribution of intercepts is
					my @thisline = split(/,/, $thisspecies[$j]);
					my $lat = $thisline[1];
					my $long = $thisline[2];
					chomp $long;
					my $this_intercept = $long - ($slope*$lat);
					push(@intercepts, $this_intercept);
					#print "$long = $slope x $lat + $this_intercept\n";
				}
				my $offset;  #The next few lines of confusing code are basically choosing which side of the distribution of intercepts we're working with
				@intercepts = sort {$a <=> $b} @intercepts;
				my $whichspecies = rand(2);
				if($whichspecies <= 1){
					$offset = $species{$speciesname} * $testprop;
					$testing = "less";
					
				}
				else{
					$offset = $species{$speciesname} * (1 - $testprop);
					$testing = "more";
				}
				#print "\n$i \t $offset\n";
				if($intercepts[$offset] == $intercepts[$offset-1]){
					$failurecount++;
					$i--;
					#print "Can't work out a solution with slope $slope for $speciesname, trying again.\n";
				} #Can't work out a solution with this slope
				else{
					$successcount++;
					my $cutoff_intercept = ($intercepts[$offset] + $intercepts[$offset-1])/2;  #If all goes well we should now have an intercept that splits the data set into sizes of species a and b
					
					for(my $j = 1; $j < @thisspecies; $j++){  #Now we're splitting up the data set
						#$thisspecies[$j] =~ s/\r/\n/g;
						my @thisline = split(/,/, $thisspecies[$j]);
						my $lat = $thisline[1];
						my $long = $thisline[2];
						chomp $long;
						if($long > (($slope*$lat) + $cutoff_intercept)){
							my $outspeciesname = $speciesname . "_rep_" . $i;
							if($testing eq "less"){print TRAININGOUTFILE "$outspeciesname,$lat,$long\n";}
							else{print TESTOUTFILE "$outspeciesname,$lat,$long\n";}
						}
						else{
							my $outspeciesname = $speciesname . "_rep_" . $i;
							if($testing eq "less"){print TESTOUTFILE "$outspeciesname,$lat,$long\n";}
							else{print TRAININGOUTFILE "$outspeciesname,$lat,$long\n";}
						}
					} 
				}
				print "$speciesname : failed $failurecount times, succeeded $successcount times.\n"
			}
			else{print "Failed to partition $speciesname 1000 times, giving up."}
		}
	}	
	close TRAININGOUTFILE;
	close TESTOUTFILE;
}

sub crossvalidation_blob{
	my $nreps = $crossvalidation_nreps_textbox -> get();
	my $testprop = $crossvalidation_testprop_textbox ->get();
	my $arrayref = shift;
	my $hashref = shift;
	my @records = @$arrayref;
	my %species = %$hashref;
	$headerline = shift;
	$trainingfilename = shift;
	my $testfilename = $trainingfilename;
	$testfilename =~ s/.csv/_test.csv/;
	open (TRAININGOUTFILE, ">$trainingfilename");
	print TRAININGOUTFILE $headerline;
	open (TESTOUTFILE, ">$testfilename");
	print TESTOUTFILE $headerline;
	foreach $speciesname (keys %species){
		my @thisspecies = ();
		for $thisrecord (@records){
			my @thisline = split (/,/, $thisrecord);
			if ($thisline[0] eq $speciesname){
				push (@thisspecies, $thisrecord);}
		}
		my $cutoffnum = $species{$speciesname} * $testprop;
		#print "$cutoffnum, $speciesname, $species{$speciesname}, $testprop\n";
		for(my $i = 0; $i < $nreps; $i++){
			fisher_yates_shuffle(\@thisspecies);
			my @focal_line = split(/,/, $thisspecies[0]);
			my $focal_lat = $focal_line[1];
			my $focal_long = $focal_line[2];
			chomp $focal_long;
			my @distances = ();
			push(@distances, 0);
			for(my $j = 1; $j < @thisspecies; $j++){  #Getting distance from focal point for every other point in file, putting into hash keyed by index in @records
				my @thisline = split(/,/, $thisspecies[$j]);
				my $lat = $thisline[1];
				my $long = $thisline[2];
				chomp $long;
				my $distance = sqrt((abs($long-$focal_long))*(abs($long-$focal_long)) + (abs($lat-$focal_lat))*(abs($lat-$focal_lat))); # Yay Pythagoras
				#print "$j\t$focal_lat\t$focal_long\t$lat\t$long\t$distance\n"; 
				push(@distances, $distance);
			}
			@distances = sort {$a <=> $b} @distances;
	        my $cutoff = $distances[$cutoffnum];
	        
	        for(my $j = 0; $j < @thisspecies; $j++){  #Getting distance from focal point for every other point in file, putting into hash keyed by index in @records
				#$thisspecies[$j] =~ s/\r/\n/g;
				my @thisline = split(/,/, $thisspecies[$j]);
				my $lat = $thisline[1];
				my $long = $thisline[2];
				chomp $long;
				my $distance = sqrt((abs($long-$focal_long))*(abs($long-$focal_long)) + (abs($lat-$focal_lat))*(abs($lat-$focal_lat))); # Yay Pythagoras
				if($distance <= $cutoff){
					my $speciesname = $speciesname . "_rep_" . $i;
					print TESTOUTFILE "$speciesname,$lat,$long\n";
				}
				else{
					my $speciesname = $speciesname . "_rep_" . $i;
					print TRAININGOUTFILE "$speciesname,$lat,$long\n";
				}
			}
		}	
	}
	close TRAININGOUTFILE;
	close TESTOUTFILE;
}


#####Functions for use in the rastersample tab

sub rastersampleAddFiles {
    my $addfiles;
    for (@rastersample_files){
    	$addfiles = $addfiles . " {$_}";
    }
    my $newfiles = Tkx::tk___getOpenFile(-multiple=>TRUE);
    unless($newfiles =~ /\}\s+\{/ || $newfiles =~ /^\{/){  # All of this shit is just to make sure that file names are parsed consistently.  ARGH TKX. WTF.
    	$newfiles =~ s/\s+/} {/g;
    	$newfiles = "{" . $newfiles . "}";
    }
    $addfiles = $addfiles . " " . $newfiles;
    $addfiles =~ s/^\s+//;
    @rastersample_files = ();
    $formatted_rastersamplefiles = "";
    #Tkx::tk___messageBox(-message=>"$addfiles");
    my @thesefiles = split(/}\s+{/, $addfiles);
    for(@thesefiles){
    	$_ =~ s/\{//;
    	$_ =~ s/\}//;
    	push (@rastersample_files, $_);
    	my @thisname = split(/\//, $_);
    	$formatted_rastersamplefiles = $formatted_rastersamplefiles . " {$thisname[-1]} ";
    }
}


sub rastersampleClearFiles {
    @rastersample_files = ();
    $formatted_rastersamplefiles = "";
}

sub rastersampleImportList{
    @rastersample_files=();
    $formatted_rastersamplefiles = "";
    my $importfile = Tkx::tk___getOpenFile();
    open(IMPORT, "$importfile");
    while(<IMPORT>) {
        my $thisfile = $_;
        chomp($thisfile);
        push(@rastersample_files, $thisfile);
        my @thisname = split(/\//, $thisfile);
    	$formatted_rastersamplefiles = $formatted_rastersamplefiles . " {$thisname[-1]} ";
    }
}

sub rastersampleExportList{
    my $exportfile = Tkx::tk___getSaveFile();
    open(EXPORT, ">$exportfile");
    for(@rastersample_files){print EXPORT "$_\n";}
    close EXPORT;
}

sub rastersampleExecute{
	my $nreps;
	my $npoints;
	if($scripting){
		$nreps = $scripting_nreps;
		$npoints = $scripting_npoints;
	}
	else{
		$nreps = $rastersample_nreps_textbox -> get();
		$npoints = $rastersample_npoints_textbox -> get();
	}
	for(my $i = 0; $i < @rastersample_files; $i ++){
		my $infile = $rastersample_files[$i];
		my $outfile = $rastersample_files[$i];
		#print "$output_directory\n$outfile";
		$outfile =~ s/.asc$/_resampled_$npoints.csv/i;
		unless($output_directory eq "Directory not set"){
			my @outline = split(/\//, $outfile);
			$outfile = $output_directory . "/" . $outline[-1];
		}
		print "Printing points to $outfile...";
		
		open(INFILE, "$infile") || die "Can't open $infile!";
		open(OUTFILE, ">$outfile") || die "Can't write to $outfile!";
		print OUTFILE "Species,longitude,latitude\n";
		my $maximum;
		my $minimum = 100000000000;
		my @sample_array;
		my @data;
		print "1...";
	    while(<INFILE>){
	         if($_=~ /^\s*[0123456789-]/){
	              chomp($_);
	              $_ =~ s/^s+//;
	              unshift(@data, $_);
	         }
	         else{ # Distinguishes file parameters from data
	              my @thisline = split(/\s+/, $_);
	              $fileparams{lc($thisline[0])} = $thisline[1]; #Keys are being converted to all lower case!
	         }
	    }
	    print "2...";
	    my $sum = 0;
	    my $xll = $fileparams{xllcorner};
	    my $yll = $fileparams{yllcorner};
	    my $cellsize = $fileparams{cellsize};
	    my $nodata = $fileparams{nodata_value};
	    my $nrows = @data;
	    for(my $i=0; $i< @data; $i++){
	         my @thisline = split(/\s+/, $data[$i]);
	         for(my $j = 0; $j < @thisline; $j++){
	         	  if($thisline[$j] != $nodata){
	         	  		#print "$thisline[$j]\n";
	              		if($rastersample_functiontype eq "exponential"){
	              			$sum += 2.71828182846**$thisline[$j];
	              		}
	              		elsif($rastersample_functiontype eq "constant"){
	              			$sum += 1;
	              		}
		              	else{$sum += $thisline[$j];}
	              	   if($thisline[$j] > $maximum){$maximum = $thisline[$j];}	
	              	   if($thisline[$j] < $minimum){$minimum = $thisline[$j];}
	                   my $thispointx = $xll + ($j * $cellsize) + ($cellsize/2); 
	                   my $thispointy = $yll + ($i * $cellsize) + ($cellsize/2);
	                   my $sampleprob;
	                   if($rastersample_functiontype eq "constant"){$sampleprob = 1;}
	                   if($rastersample_functiontype eq "linear"){$sampleprob = $thisline[$j];}
	                   if($rastersample_functiontype eq "exponential"){$sampleprob = 2.71828182846**$thisline[$j];} 
	                   my $thispoint = $sampleprob . "," . $thispointx . "," . $thispointy;
	                   push(@sample_array, $thispoint);
	                   #print "$thispoint\n";
	              }
	         }
	    }
	    print "3...";
	    if($rastersample_functiontype eq "constant"){
	    	$maximum = 1;
	    	$minimum = 0;
	    }
	    if($rastersample_functiontype eq "exponential"){
	    	$maximum = 2.71828182846**$maximum;
	    	$minimum = 2.71828182846**$minimum;
	    }
	    
	    my $range = $maximum;
	    #print "Min: $minimum\tMax: $maximum\tRange: $range\tSum: $sum\n";
	    @original_array = @sample_array;
	    for(my $j = 0; $j < $nreps; $j++){
	    	@sample_array = @original_array;
	    	my @tempname = split(/\//,$outfile);
	    	my $speciesname = $tempname[-1];
	    	$speciesname =~ s/.csv/_rep_$j/i;
	    	my $pointcount = 0;
	    	my $k = 0;
	    	fisher_yates_shuffle(\@sample_array);
	    	while($pointcount < $npoints){
	    		#print"$j\t$pointcount\t$sum\n";
	    		my $thisnum = rand($sum);
	    		my $thissum = 0;
	    		my @thisline = ();
	    		while($thissum <= $thisnum){
	    			if($k == @sample_array){$k = 0;}

	    			@thisline = split(/,/, $sample_array[$k]);
	    			$thissum += $thisline[0];
	    			$k++;
	    			#print "$thissum\t$thisnum\t$k\n";
	    		}
	    		if($rastersample_replace eq "no"){splice(@sample_array, $k, 1);}
	    		print OUTFILE "$speciesname,$thisline[1],$thisline[2]\n";
	    		$pointcount++;
	    	}	
	    }
	    
		
		close OUTFILE;
		close INFILE;
		print "DONE!\n";
	}
}


####Functions for use in the Rangebreak tab
sub rangebreakAddFiles {
    my $addfiles;
    for (@rangebreak_files){
    	$addfiles = $addfiles . " {$_}";
    }
    my $newfiles = Tkx::tk___getOpenFile(-multiple=>TRUE);
    unless($newfiles =~ /\}\s+\{/ || $newfiles =~ /^\{/){  # All of this shit is just to make sure that file names are parsed consistently.  ARGH TKX. WTF.
    	$newfiles =~ s/\s+/} {/g;
    	$newfiles = "{" . $newfiles . "}";
    }
    $addfiles = $addfiles . " " . $newfiles;
    $addfiles =~ s/^\s+//;
    @rangebreak_files = ();
    $formatted_rangebreakfiles = "";
    #Tkx::tk___messageBox(-message=>"$addfiles");
    my @thesefiles = split(/}\s+{/, $addfiles);
    for(@thesefiles){
    	$_ =~ s/\{//;
    	$_ =~ s/\}//;
    	push (@rangebreak_files, $_);
    	my @thisname = split(/\//, $_);
    	$formatted_rangebreakfiles = $formatted_rangebreakfiles . " {$thisname[-1]} ";
    }
}


sub rangebreakClearFiles {
    @rangebreak_files = ();
    $formatted_rangebreakfiles = '';
}

sub rangebreakImportList{
    @rangebreak_files=();
    $formatted_rangebreakfiles = "";
    my $importfile = Tkx::tk___getOpenFile();
    open(IMPORT, "$importfile");
    while(<IMPORT>) {
        my $thisfile = $_;
        chomp($thisfile);
        push(@rangebreak_files, $thisfile);
        my @thisname = split(/\//, $thisfile);
    	$formatted_rangebreakfiles = $formatted_rangebreakfiles . " {$thisname[-1]} ";
    }
}

sub rangebreakExportList{
    my $exportfile = Tkx::tk___getSaveFile();
    open(EXPORT, ">$exportfile");
    for(@rangebreak_files){print EXPORT "$_\n";}
    close EXPORT;
}

sub rangebreakExecute{
	my $ready_to_go = 1;
	my $nreps = $rangebreak_nreps_textbox -> get();
	my $ribbonwidth;
	if ($rangebreak_breaktype eq "ribbon"){$ribbonwidth = $rangebreak_ribbonwidth_textbox -> get();}
	if ($rangebreak_breaktype eq "ribbon" && $ribbonwidth !~ /\d+/){
		$ready_to_go = 0;
		Tkx::tk___messageBox(-message=>"Got value $ribbonwidth.  Ribbon width has to be a number when using \"ribbon\" as the break type.");
	}
	if($ready_to_go){
		#print "keepreps is $rangebreak_keepreps\n";
		for(my $analyses = 0; $analyses < @rangebreak_files; $analyses++){
			my $q;
		    my $z;
		    my $optionj;
		    if ($options_show_maxent eq "no"){$z = "-z";}
		    else {$z = "";}
		    if($suitability_type =~ /ra/i){
		    	if($options_maxent_version eq "old"){$q = "-Q";}
		    	else{$q = "outputformat=raw";}
		    }
		    if($suitability_type =~ /cu/i){
		    	if($options_maxent_version eq "old"){$q = "-C";}
		    	else{$q = "outputformat=cumulative";}
		    }
		    if($suitability_type =~ /lo/i){$q = "";}
		    if(-d $projectiondir){$optionj = "projectionlayers=\"$projectiondir\"";} #Done this strange way because it's not always going to be set
		    my $bias = '';
        if(-e $biasfile_path){$bias = "biasfile=\"" . $biasfile_path . "\"";}
		    my %species = ();
        my @records = ();
		    my $headerline;
		    my $i=0;
		    open(INFILE, "$rangebreak_files[$analyses]") || Tkx::tk___messageBox(-message=>"Can't open $rangebreak_files[$analyses]");
			while(<INFILE>){
				push(@records, $_);
			    if($i == 0){
			    	$headerline = $_;
			    }
			    if($i > 0){
			         my @thisline = split(/,/, $_);
			         my $thisspecies = $thisline[0];
			         $species{$thisspecies} += 1;
			    }
			    $i++;
			}
			close INFILE;
			print "Species\t\t\tRecords\n";
			$fileprefix = "";
			foreach my $j( keys(%species)){
			 	print"$j\t\t\t$species{$j}\n";
			 	$fileprefix = $fileprefix . $j . "_";
			}
			chop($fileprefix); 
			
			$repsfile = $output_directory . "/" . $fileprefix . "_rangebreak_reps.csv"; #Filename for reps
			my $numspecies = keys(%species);
			if($numspecies != 2){Tkx::tk___messageBox(-message=>"Files for rangebreaker need to contain two, and only two species!");}
			else{  # It's go time!
				if($rangebreak_breaktype eq  "line"){rangebreak_line(\@records, \%species, $headerline, $repsfile);}
				elsif($rangebreak_breaktype eq  "blob"){rangebreak_blob(\@records, \%species, $headerline, $repsfile);}
				elsif($rangebreak_breaktype eq "ribbon"){rangebreak_ribbon(\@records, \%species, $headerline, $repsfile, $ribbonwidth);} 
				else{Tkx::tk___messageBox(-message=>"Problem: breaktype is $rangebreak_breaktype!");}
			}
			
			if($rangebreak_runmaxent ==1){
					
				##### At this point there should be a file called temp_rangebreaker.csv that has reps in it
				system("java $memory -jar \"$maxent_path\" -e \"$layers_path\" samplesfile=\"$repsfile\" $optionj $q $z -r -a -b $maxent_beta -o \"$output_directory\" -t categ $pictures $rocplots $responsecurves $bias $removedupes nowarnings");
			    
				##### Here we're doing the overlap script on the ASCII files
				if($rangebreak_breaktype eq "ribbon"){ #Overlap and cleanup on ribbon analysis.  Separate because we want to make four comparisons (A-R, B-R, A-B, A+B-R).
					my $rangebreakoutfile = $output_directory . "/RANGEBREAK_A_vs_B_" . $fileprefix . ".csv"; #Filename for final summary of species A vs. species B
					open(RANGEBREAKOUT, ">$rangebreakoutfile")|| die "Can't open $rangebreakoutfile for writing!\n";
				    print RANGEBREAKOUT "I,Schoener's D,Relative Rank,Replicate\n";
				    for(my $n = 0; $n < $nreps; $n++){
				    	my $firstasc = $output_directory . "/rep_" .$n . "_species1.asc";
				        my $secondasc = $output_directory . "/rep_" .$n . "_species2.asc";;
				        @overlap_files = ();
					    push(@overlap_files, $firstasc);
					    push(@overlap_files, $secondasc);
					    #print "sending  @overlap_files\n";
					    overlapExecute();
						my $ifile = $output_directory . "/" . $fileprefix . "_I_output.csv";
						my $dfile = $output_directory . "/" . $fileprefix . "_D_output.csv";
						my $relrankfile = $output_directory . "/" . $fileprefix . "_relrank_output.csv";
						#print "$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
						open(IFILE, "$ifile");
						my @thisarray = <IFILE>;
						my @thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						close IFILE;
						open(DFILE, "$dfile");
						@thisarray = <DFILE>;
						@thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						close DFILE;
						open(RELRANKFILE, "$relrankfile");
						@thisarray = <RELRANKFILE>;
						@thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						print RANGEBREAKOUT "$n\n";
						close RELRANKFILE;
				    }	
				    close RANGEBREAKOUT;
					open(TEMPRANGEBREAK, "$rangebreakoutfile");
					my @results = <TEMPRANGEBREAK>;
					close TEMPRANGEBREAK;
					$sortedrangebreakoutfile = $rangebreakoutfile;
					$sortedrangebreakoutfile =~ s/.csv/_sorted.csv/;
					print $sortedrangebreakoutfile;
					my @sortedI = ();
					my @sortedD = ();
					my @sortedRELRANK = ();
					open(SORTEDRANGEBREAK, ">$sortedrangebreakoutfile");
					print SORTEDRANGEBREAK "I,Schoener's D,Relative Rank\n";
					for(my $i = 1; $i < @results; $i++){
					    my @thisline = split(/,/, $results[$i]);
					    push(@sortedI, $thisline[0]);
					    push(@sortedD, $thisline[1]);
					    push(@sortedRELRANK, $thisline[2]);
					    @sortedI = sort {$a <=> $b} (@sortedI);
					    @sortedD = sort {$a <=> $b} (@sortedD);
					    @sortedRELRANK = sort {$a <=> $b} (@sortedRELRANK);
					 }
					 for(my $j = 0; $j < @results; $j++){
					    if($sortedI[$j]){print SORTEDRANGEBREAK "$sortedI[$j],$sortedD[$j],$sortedRELRANK[$j]\n";}
					    ### ^^ Had to add an if statement because it was going over for some odd reason.
					 }
					 @results = ();
					 @sortedI = ();
					 @sortedD = ();
					 @sortedRELRANK = ();
					 close SORTEDRANGEBREAK;	
					 
					 
					$rangebreakoutfile = $output_directory . "/RANGEBREAK_A_vs_Ribbon_" . $fileprefix . ".csv"; #Filename for final summary of A vs. ribbon
					open(RANGEBREAKOUT, ">$rangebreakoutfile")|| die "Can't open $rangebreakoutfile for writing!\n";
				    print RANGEBREAKOUT "I,Schoener's D,RElative Rank,Replicate\n";
				    for(my $n = 0; $n < $nreps; $n++){
				    	my $firstasc = $output_directory . "/rep_" .$n . "_species1.asc";
				        my $secondasc = $output_directory . "/rep_" .$n . "_ribbon.asc";;
				        @overlap_files = ();
					    push(@overlap_files, $firstasc);
					    push(@overlap_files, $secondasc);
					    #print "sending  @overlap_files\n";
					    overlapExecute();
						my $ifile = $output_directory . "/" . $fileprefix . "_I_output.csv";
						my $dfile = $output_directory . "/" . $fileprefix . "_D_output.csv";
						my $relrankfile = $output_directory . "/" . $fileprefix . "_relrank_output.csv";
						#print "$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
						open(IFILE, "$ifile");
						my @thisarray = <IFILE>;
						my @thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						close IFILE;
						open(DFILE, "$dfile");
						@thisarray = <DFILE>;
						@thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						close DFILE;
						open(RELRANKFILE, "$relrankfile");
						@thisarray = <RELRANKFILE>;
						@thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						print RANGEBREAKOUT "$n\n";
						close RELRANKFILE;
				    }	
				    close RANGEBREAKOUT;
					open(TEMPRANGEBREAK, "$rangebreakoutfile");
					@results = <TEMPRANGEBREAK>;
					close TEMPRANGEBREAK;
					$sortedrangebreakoutfile = $rangebreakoutfile;
					$sortedrangebreakoutfile =~ s/.csv/_sorted.csv/;
					print $sortedrangebreakoutfile;
					@sortedI;
					@sortedD;
					@sortedRELRANK;
					open(SORTEDRANGEBREAK, ">$sortedrangebreakoutfile");
					print SORTEDRANGEBREAK "I,Schoener's D,Relative Rank\n";
					for(my $i = 1; $i < @results; $i++){
					    my @thisline = split(/,/, $results[$i]);
					    push(@sortedI, $thisline[0]);
					    push(@sortedD, $thisline[1]);
					    push(@sortedRELRANK, $thisline[2]);
					    @sortedI = sort {$a <=> $b} (@sortedI);
					    @sortedD = sort {$a <=> $b} (@sortedD);
					    @sortedRELRANK = sort {$a <=> $b} (@sortedRELRANK);
					 }
					 for(my $j = 0; $j < @results; $j++){
					    if($sortedI[$j]){print SORTEDRANGEBREAK "$sortedI[$j],$sortedD[$j],$sortedRELRANK[$j]\n";}
					    ### ^^ Had to add an if statement because it was going over for some odd reason.
					 }
					 @results = ();
					 @sortedI = ();
					 @sortedD = ();
					 @sortedRELRANK = ();
					 close SORTEDRANGEBREAK;	
					 

					$rangebreakoutfile = $output_directory . "/RANGEBREAK_B_vs_Ribbon_" . $fileprefix . ".csv"; #Filename for final summary of A vs. ribbon
					open(RANGEBREAKOUT, ">$rangebreakoutfile")|| die "Can't open $rangebreakoutfile for writing!\n";
				    print RANGEBREAKOUT "I,Schoener's D,Relative Rank,Replicate\n";
				    for(my $n = 0; $n < $nreps; $n++){
				    	my $firstasc = $output_directory . "/rep_" .$n . "_species2.asc";
				        my $secondasc = $output_directory . "/rep_" .$n . "_ribbon.asc";;
				        @overlap_files = ();
					    push(@overlap_files, $firstasc);
					    push(@overlap_files, $secondasc);
					    #print "sending  @overlap_files\n";
					    overlapExecute();
						my $ifile = $output_directory . "/" . $fileprefix . "_I_output.csv";
						my $dfile = $output_directory . "/" . $fileprefix . "_D_output.csv";
						my $relrankfile = $output_directory . "/" . $fileprefix . "_relrank_output.csv";
						#print "$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
						open(IFILE, "$ifile");
						my @thisarray = <IFILE>;
						my @thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						close IFILE;
						open(DFILE, "$dfile");
						@thisarray = <DFILE>;
						@thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						close DFILE;
						open(RELRANKFILE, "$relrankfile");
						@thisarray = <RELRANKFILE>;
						@thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						print RANGEBREAKOUT "$n\n";
						close RELRANKFILE;
						}	
				    close RANGEBREAKOUT;
					open(TEMPRANGEBREAK, "$rangebreakoutfile");
					@results = <TEMPRANGEBREAK>;
					close TEMPRANGEBREAK;
					$sortedrangebreakoutfile = $rangebreakoutfile;
					$sortedrangebreakoutfile =~ s/.csv/_sorted.csv/;
					print $sortedrangebreakoutfile;
					@sortedI;
					@sortedD;
					@sortedRELRANK;
					open(SORTEDRANGEBREAK, ">$sortedrangebreakoutfile");
					print SORTEDRANGEBREAK "I,Schoener's D,Relative Rank\n";
					for(my $i = 1; $i < @results; $i++){
					    my @thisline = split(/,/, $results[$i]);
					    push(@sortedI, $thisline[0]);
					    push(@sortedD, $thisline[1]);
					    push(@sortedRELRANK, $thisline[1]);
					    @sortedI = sort {$a <=> $b} (@sortedI);
					    @sortedD = sort {$a <=> $b} (@sortedD);
					    @sortedRELRANK = sort {$a <=> $b} (@sortedRELRANK);
					 }
					 for(my $j = 0; $j < @results; $j++){
					    if($sortedI[$j]){print SORTEDRANGEBREAK "$sortedI[$j],$sortedD[$j],$sortedRELRANK[$j]\n";}
					    ### ^^ Had to add an if statement because it was going over for some odd reason.
					 }
					 @results = ();
					 @sortedI = ();
					 @sortedD = ();
					 @sortedRELRANK = ();
					 close SORTEDRANGEBREAK;	
					 
					 $rangebreakoutfile = $output_directory . "/RANGEBREAK_A_and_B_vs_Ribbon_" . $fileprefix . ".csv"; #Filename for final summary of A vs. ribbon
					open(RANGEBREAKOUT, ">$rangebreakoutfile")|| die "Can't open $rangebreakoutfile for writing!\n";
				    print RANGEBREAKOUT "I,Schoener's D,Relative Rank,Replicate\n";
				    for(my $n = 0; $n < $nreps; $n++){
				    	my $firstasc = $output_directory . "/rep_" .$n . "_merged.asc";
				        my $secondasc = $output_directory . "/rep_" .$n . "_ribbon.asc";;
				        @overlap_files = ();
					    push(@overlap_files, $firstasc);
					    push(@overlap_files, $secondasc);
					    #print "sending  @overlap_files\n";
					    overlapExecute();
						my $ifile = $output_directory . "/" . $fileprefix . "_I_output.csv";
						my $dfile = $output_directory . "/" . $fileprefix . "_D_output.csv";
						my $relrankfile = $output_directory . "/" . $fileprefix . "_relrank_output.csv";
						#print "$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
						open(IFILE, "$ifile");
						my @thisarray = <IFILE>;
						my @thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						close IFILE;
						open(DFILE, "$dfile");
						@thisarray = <DFILE>;
						@thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						close DFILE;
						open(RELRANKFILE, "$relrankfile");
						@thisarray = <RELRANKFILE>;
						@thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						print RANGEBREAKOUT "$n\n";
						close RELRANKFILE;
				    }	
				    close RANGEBREAKOUT;
					open(TEMPRANGEBREAK, "$rangebreakoutfile");
					@results = <TEMPRANGEBREAK>;
					close TEMPRANGEBREAK;
					$sortedrangebreakoutfile = $rangebreakoutfile;
					$sortedrangebreakoutfile =~ s/.csv/_sorted.csv/;
					print $sortedrangebreakoutfile;
					@sortedI;
					@sortedD;
					@sortedRELRANK;
					open(SORTEDRANGEBREAK, ">$sortedrangebreakoutfile");
					print SORTEDRANGEBREAK "I,Schoener's D,Relative Rank\n";
					for(my $i = 1; $i < @results; $i++){
					    my @thisline = split(/,/, $results[$i]);
					    push(@sortedI, $thisline[0]);
					    push(@sortedD, $thisline[1]);
					    push(@sortedRELRANK, $thisline[2]);
					    @sortedI = sort {$a <=> $b} (@sortedI);
					    @sortedD = sort {$a <=> $b} (@sortedD);
					    @sortedRELRANK = sort {$a <=> $b} (@sortedRELRANK);
					 }
					 for(my $j = 0; $j < @results; $j++){
					    if($sortedI[$j]){print SORTEDRANGEBREAK "$sortedI[$j],$sortedD[$j],$sortedRELRANK[$j]\n";}
					    ### ^^ Had to add an if statement because it was going over for some odd reason.
					 }
					 @results = ();
					 @sortedI = ();
					 @sortedD = ();
					 @sortedRELRANK = ();
					 close SORTEDRANGEBREAK;	
					 					 
					 #####Cleanup
					 if($rangebreak_keepreps == 1){}
						else{
						    $ifile =~ tr/\//\\/;
						    $dfile =~ tr/\//\\/;
						#    print "\n\n$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
						    unlink("$ifile");
						    unlink("$dfile");
						    unlink("$relrankfile");
						    unlink("$firstasc");
						    unlink("$secondasc");
						    $firstasc =~ s/.asc/.html/;
						    $secondasc =~ s/.asc/.html/;
						    unlink("$firstasc");
						    unlink("$secondasc");
						    $firstasc =~ s/.html/.lambdas/;
						    $secondasc =~ s/.html/.lambdas/;
						    unlink("$firstasc");
						    unlink("$secondasc");
						    $firstasc =~ s/.lambdas/_omission.csv/;
						    $secondasc =~ s/.lambdas/_omission.csv/;
						    unlink("$firstasc");
						    unlink("$secondasc");
						    $firstasc =~ s/_omission.csv/_samplePredictions.csv/;
						    $secondasc =~ s/_omission.csv/_samplePredictions.csv/;
						    unlink("$firstasc");
						    unlink("$secondasc");
					}
				}				
			    else{  #Overlaps and cleanup for line/blob
				    my $rangebreakoutfile = $output_directory . "/RANGEBREAK_" . $fileprefix . ".csv"; #Filename for final summary
					open(RANGEBREAKOUT, ">$rangebreakoutfile")|| die "Can't open $rangebreakoutfile for writing!\n";
				    print RANGEBREAKOUT "I,Schoener's D,Relative Rank,Replicate\n";
				    for(my $n = 0; $n < $nreps; $n++){
				    	my $firstasc = $output_directory . "/rep_" .$n . "_species1.asc";
				        my $secondasc = $output_directory . "/rep_" .$n . "_species2.asc";;
				        @overlap_files = ();
					    push(@overlap_files, $firstasc);
					    push(@overlap_files, $secondasc);
					    #print "sending  @overlap_files\n";
					    overlapExecute();
						my $ifile = $output_directory . "/" . $fileprefix . "_I_output.csv";
						my $dfile = $output_directory . "/" . $fileprefix . "_D_output.csv";
						my $relrankfile = $output_directory . "/" . $fileprefix . "_relrank_output.csv";
						#print "$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
						open(IFILE, "$ifile");
						my @thisarray = <IFILE>;
						my @thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						close IFILE;
						open(DFILE, "$dfile");
						@thisarray = <DFILE>;
						@thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						close DFILE;
						open(RELRANKFILE, "$relrankfile");
						@thisarray = <RELRANKFILE>;
						@thisline = split(/,/, $thisarray[1]);
						chomp($thisline[2]);
						print RANGEBREAKOUT "$thisline[2],";
						print RANGEBREAKOUT "$n\n";
						close RELRANKFILE;
						if($rangebreak_keepreps == 1){}
						else{
						    $ifile =~ tr/\//\\/;
						    $dfile =~ tr/\//\\/;
						#    print "\n\n$symfile\n$diffile\n$dirfile\n$ifile\n$dfile\n\n";
						    unlink("$ifile");
						    unlink("$dfile");
						    unlink("$relrankfile");
						    unlink("$firstasc");
						    unlink("$secondasc");
						    $firstasc =~ s/.asc/.html/;
						    $secondasc =~ s/.asc/.html/;
						    unlink("$firstasc");
						    unlink("$secondasc");
						    $firstasc =~ s/.html/.lambdas/;
						    $secondasc =~ s/.html/.lambdas/;
						    unlink("$firstasc");
						    unlink("$secondasc");
						    $firstasc =~ s/.lambdas/_omission.csv/;
						    $secondasc =~ s/.lambdas/_omission.csv/;
						    unlink("$firstasc");
						    unlink("$secondasc");
						    $firstasc =~ s/_omission.csv/_samplePredictions.csv/;
						    $secondasc =~ s/_omission.csv/_samplePredictions.csv/;
						    unlink("$firstasc");
						    unlink("$secondasc");
						}
				    }	
				    close RANGEBREAKOUT;
					open(TEMPRANGEBREAK, "$rangebreakoutfile");
					my @results = <TEMPRANGEBREAK>;
					close TEMPRANGEBREAK;
					$sortedrangebreakoutfile = $rangebreakoutfile;
					$sortedrangebreakoutfile =~ s/.csv/_sorted.csv/;
					print $sortedrangebreakoutfile;
					my @sortedI;
					my @sortedD;
					my @sortedRELRANK;
					open(SORTEDRANGEBREAK, ">$sortedrangebreakoutfile");
					print SORTEDRANGEBREAK "I,Schoener's D,Relative Rank\n";
					for(my $i = 1; $i < @results; $i++){
					    my @thisline = split(/,/, $results[$i]);
					    push(@sortedI, $thisline[0]);
					    push(@sortedD, $thisline[1]);
					    push(@sortedRELRANK, $thisline[2]);
					    @sortedI = sort {$a <=> $b} (@sortedI);
					    @sortedD = sort {$a <=> $b} (@sortedD);
					    @sortedRELRANK = sort {$a <=> $b} (@sortedRELRANK);
					 }
					 for(my $j = 0; $j < @results; $j++){
					    if($sortedI[$j]){print SORTEDRANGEBREAK "$sortedI[$j],$sortedD[$j],$sortedRELRANK[$j]\n";}
					    ### ^^ Had to add an if statement because it was going over for some odd reason.
					 }
					 close SORTEDRANGEBREAK;
					 @results = ();
					 @sortedI = ();
					 @sortedD = ();	
					 @sortedRELRANK = ();	
				}	
			}
		}
	}
}

sub rangebreak_ribbon{
	my $nreps = $rangebreak_nreps_textbox -> get();
	my $arrayref = shift;
	my $hashref = shift;
	my @records = @$arrayref;
	my %species = %$hashref;
	$headerline = shift;
	$filename = shift;
	$ribbonwidth = shift;
	my $logfile = $filename;
	print "$logfile\n";
	$logfile =~ s/rangebreak_reps.csv/rangebreak_logfile.csv/;
	open(LOGFILE, ">$logfile");
	print LOGFILE "Rep,Species A, Species B, Ribbon\n";
	open (OUTFILE, ">$filename");
	print OUTFILE $headerline;
	for(my $i = 0; $i < $nreps; $i++){
		my $acounter = 0;
		my $bcounter = 0;
		my $ribboncounter = 0;
		my @intercepts = (); 
		my $angle = rand(3.1415926535);  #Randomly picking slope and sign
		my $intercept_modifier = ($ribbonwidth/2)/cos($angle); #This will be used to move the top and bottom halves of the ribbon
		if($angle > 3.1415926535/2){$intercept_modifier = -$intercept_modifier;}
		#my $plusminus = rand(2);
		my $slope = (sin($angle)/cos($angle)); 
		#if($plusminus <= 1){$slope = 0 - $slope;}
		#print "slope is $slope\n";
		my @species1 = ();
		my @species2 = ();
		for(my $j = 1; $j < @records; $j++){  #Figuring out what the distribution of intercepts is
			my @thisline = split(/,/, $records[$j]);
			my $lat = $thisline[1];
			my $long = $thisline[2];
			chomp $long;
			my $this_intercept = $long - ($slope*$lat);
			push(@intercepts, $this_intercept);
			#print "$long = $slope x $lat + $this_intercept\n";
		}
		my $offset;  #The next few lines of confusing code are basically choosing which side of the distribution of intercepts we're working with
		@intercepts = sort {$a <=> $b} @intercepts;
		my @specieskeys = keys(%species);
		my $whichspecies = rand(2);
		if($whichspecies <= 1){$offset = $species{$specieskeys[0]};}
		else{$offset = $species{$specieskeys[1]};}
		#print "\n$i \t $offset\n";
		if($intercepts[$offset] == $intercepts[$offset-1]){
			$i--;
			print "Can't work out a solution with this slope, trying again.\n";
		} #Can't work out a solution with this slope
		else{
			#print "Run $i: slope is $slope, intercept mod is $intercept_modifier\n";
			my $cutoff_intercept_high = ($intercepts[$offset] + $intercepts[$offset-1])/2 + $intercept_modifier;  
			my $cutoff_intercept_low = ($intercepts[$offset] + $intercepts[$offset-1])/2 - $intercept_modifier;  
			for(my $j = 1; $j < @records; $j++){  #Now we're splitting up the data set
				my @thisline = split(/,/, $records[$j]);
				my $lat = $thisline[1];
				my $long = $thisline[2];
				chomp $long;
				if($long > (($slope*$lat) + $cutoff_intercept_high)){
					$acounter++;
					my $mergedname = "rep_" . $i . "_merged"; #This is for A+B compared to R
					my $latlong = "$lat,$long\n";
					push(@species1, $latlong);
					print OUTFILE "$mergedname,$lat,$long\n";
				}
				elsif(($long < (($slope*$lat) + $cutoff_intercept_high)) && ($long > (($slope*$lat) + $cutoff_intercept_low))){
					$ribboncounter++;
					my $speciesname = "rep_" . $i . "_ribbon";
					print OUTFILE "$speciesname,$lat,$long\n";
				}
				else{
					$bcounter++;
					my $mergedname = "rep_" . $i . "_merged"; #This is for A+B compared to R
					my $latlong = "$lat,$long\n";
					push(@species2, $latlong);
					print OUTFILE "$mergedname,$lat,$long\n";
				}
			} 
			if($acounter >= $bcounter){  # This next bit is so that species 1 in the reps file is always the larger sample size of the two
				print LOGFILE "$i,$acounter,$bcounter,$ribboncounter\n";
				for(my $j = 0; $j < @species1; $j++){
					print OUTFILE "rep_" . $i . "_species1," . $species1[$j];
				}
				for(my $j = 0; $j < @species2; $j++){
					print OUTFILE "rep_" . $i . "_species2," . $species2[$j];
				}
			}
			else{
				print LOGFILE "$i,$bcounter,$acounter,$ribboncounter\n";
				for(my $j = 0; $j < @species2; $j++){
					print OUTFILE "rep_" . $i . "_species1," . $species2[$j];
				}
				for(my $j = 0; $j < @species1; $j++){
					print OUTFILE "rep_" . $i . "_species2," . $species1[$j];
				}
			}
		}
	}
	close LOGFILE;
	close OUTFILE;
}

sub rangebreak_line{
	my $nreps = $rangebreak_nreps_textbox -> get();
	my $arrayref = shift;
	my $hashref = shift;
	my @records = @$arrayref;
	my %species = %$hashref;
	$headerline = shift;
	$filename = shift;
	open (OUTFILE, ">$filename");
	print OUTFILE $headerline;
	for(my $i = 0; $i < $nreps; $i++){
		my @intercepts = (); 
		my $angle = rand(90);  #Randomly picking slope and sign
		my $plusminus = rand(2);
		my $slope = (sin($angle)/cos($angle)); 
		if($plusminus <= 1){$slope = 0 - $slope;}
		#print "slope is $slope\n";
		
		for(my $j = 1; $j < @records; $j++){  #Figuring out what the distribution of intercepts is
			my @thisline = split(/,/, $records[$j]);
			my $lat = $thisline[1];
			my $long = $thisline[2];
			chomp $long;
			my $this_intercept = $long - ($slope*$lat);
			push(@intercepts, $this_intercept);
			#print "$long = $slope x $lat + $this_intercept\n";
		}
		my $offset;  #The next few lines of confusing code are basically choosing which side of the distribution of intercepts we're working with
		@intercepts = sort {$a <=> $b} @intercepts;
		my @specieskeys = keys(%species);
		my $whichspecies = rand(2);
		if($whichspecies <= 1){$offset = $species{$specieskeys[0]};}
		else{$offset = $species{$specieskeys[1]};}
		#print "\n$i \t $offset\n";
		my @species1 = ();
		my @species2 = ();
		if($intercepts[$offset] == $intercepts[$offset-1]){
			$i--;
			print "Can't work out a solution with this slope, trying again.\n";
		} #Can't work out a solution with this slope
		else{
			my $cutoff_intercept = ($intercepts[$offset] + $intercepts[$offset-1])/2;  #If all goes well we should now have an intercept that splits the data set into sizes of species a and b
			
			for(my $j = 1; $j < @records; $j++){  #Now we're splitting up the data set
				my @thisline = split(/,/, $records[$j]);
				my $lat = $thisline[1];
				my $long = $thisline[2];
				chomp $long;
				if($long > (($slope*$lat) + $cutoff_intercept)){
					my $latlong = "$lat,$long\n";
					push(@species1, $latlong);
				}
				else{
					my $latlong = "$lat,$long\n";
					push(@species2, $latlong);
				}
			} 
		}
		if(@species1 > @species2){
			
			for(my $j = 0; $j < @species1; $j++){
				print OUTFILE "rep_" . $i . "_species1," . $species1[$j];
			}
			for(my $j = 0; $j < @species2; $j++){
				print OUTFILE "rep_" . $i . "_species2," . $species2[$j];
			}
		}
		else{
			for(my $j = 0; $j < @species2; $j++){
				print OUTFILE "rep_" . $i . "_species1," . $species2[$j];
			}
			for(my $j = 0; $j < @species1; $j++){
				print OUTFILE "rep_" . $i . "_species2," . $species1[$j];
			}
		}
		#my $speciesname = "rep_" . $i . "_species2";
	}
	close OUTFILE;
}

sub rangebreak_blob{
	my $arrayref = shift;
	my $hashref = shift;
	my @temprecords = @$arrayref;
	shift(@temprecords); #getting rid of header line
	my %species = %$hashref;
	$headerline = shift;
	my @specieskeys = keys(%species);
	my $cutoffnum = $species{$specieskeys[1]};
	$filename = shift;
	open (OUTFILE, ">$filename");
	print OUTFILE $headerline;
	my $nreps = $rangebreak_nreps_textbox -> get();
	for(my $i = 0; $i < $nreps; $i++){
		fisher_yates_shuffle(\@temprecords);
		my @focal_line = split(/,/, $temprecords[0]);
		my $focal_lat = $focal_line[1];
		my $focal_long = $focal_line[2];
		chomp $focal_long;
		my @distances = ();
		push(@distances, 0);
		for(my $j = 1; $j < @temprecords; $j++){  #Getting distance from focal point for every other point in file, putting into hash keyed by index in @records
			my @thisline = split(/,/, $temprecords[$j]);
			my $lat = $thisline[1];
			my $long = $thisline[2];
			chomp $long;
			my $distance = sqrt((abs($long-$focal_long))*(abs($long-$focal_long)) + (abs($lat-$focal_lat))*(abs($lat-$focal_lat))); # Yay Pythagoras
			#print "$j\t$focal_lat\t$focal_long\t$lat\t$long\t$distance\n"; 
			push(@distances, $distance);
		}
		@distances = sort {$a <=> $b} @distances;
        my $cutoff = $distances[$cutoffnum];
        
        for(my $j = 0; $j < @temprecords; $j++){  #Getting distance from focal point for every other point in file, putting into hash keyed by index in @records
			my @thisline = split(/,/, $temprecords[$j]);
			my $lat = $thisline[1];
			my $long = $thisline[2];
			chomp $long;
			my $distance = sqrt((abs($long-$focal_long))*(abs($long-$focal_long)) + (abs($lat-$focal_lat))*(abs($lat-$focal_lat))); # Yay Pythagoras
			if($distance < $cutoff){
				my $speciesname = "rep_" . $i . "_species1";
				print OUTFILE "$speciesname,$lat,$long\n";
			}
			else{
				my $speciesname = "rep_" . $i . "_species2";
				print OUTFILE "$speciesname,$lat,$long\n";
			}
		}
	}
	close OUTFILE;
}


####Functions for use in the Tools tab
sub toolsSignTest{
	our $signtestWindow =  $mw->Toplevel;
    $signtestWindow->geometry("500x500");
    $signtestWindow->title("Sign Test");
	
	our $signtest_list_label1 = $signtestWindow -> Label(-text => "Batch 1:  ") -> grid(-row=>1, -column=>1, -pady=>5);
	our $signtest_list_addbutton1 = $signtestWindow -> Button(-text=>"Add files",-width=>20, -command=>\&signtestAddFiles1) -> grid(-row=>2, -column=>1, -padx=>5);
	our $signtest_list_clear1 = $signtestWindow -> Button(-text=>"Clear file list", -width=>20, -command=>\&signtestClearFiles1, -foreground=>'red') -> grid(-row=>3, -column=>1, -padx=>5);
	our $signtest_files_frame1 = $signtestWindow -> Frame();
	our $signtest_files_list1 = $signtest_files_frame1 -> Text(-width=>40, -height=>5);
	our $signtest_files_scrollbar1 = $signtest_files_frame1 -> Scrollbar(-orient=>'v',-command=>[yview => $signtest_files_list1]);
	$signtest_files_list1 -> configure(-yscrollcommand=>['set', $signtest_files_scrollbar1]);
	$signtest_files_list1 -> grid(-row=>1, -column=>1);
	$signtest_files_frame1 -> grid(-row=>1, -column=>2, -rowspan=>3, -pady=>10);
	$signtest_files_scrollbar1 -> grid(-row=>1, -column=>2, -sticky=>"ns");
	
	our $signtest_list_label2 = $signtestWindow -> Label(-text => "Batch 2:  ") -> grid(-row=>4, -column=>1, -pady=>5);
	our $signtest_list_addbutton2 = $signtestWindow -> Button(-text=>"Add files",-width=>20, -command=>\&signtestAddFiles2) -> grid(-row=>5, -column=>1, -padx=>5);
	our $signtest_list_clear2 = $signtestWindow -> Button(-text=>"Clear file list", -width=>20, -command=>\&signtestClearFiles2, -foreground=>'red') -> grid(-row=>6, -column=>1, -padx=>5);
	our $signtest_files_frame2 = $signtestWindow -> Frame();
	our $signtest_files_list2 = $signtest_files_frame2 -> Text(-width=>40, -height=>5);
	our $signtest_files_scrollbar2 = $signtest_files_frame2 -> Scrollbar(-orient=>'v',-command=>[yview => $signtest_files_list1]);
	$signtest_files_list2 -> configure(-yscrollcommand=>['set', $signtest_files_scrollbar2]);
	$signtest_files_list2 -> grid(-row=>1, -column=>1);
	$signtest_files_frame2 -> grid(-row=>4, -column=>2, -rowspan=>3, -pady=>10);
	$signtest_files_scrollbar2 -> grid(-row=>1, -column=>2, -sticky=>"ns");
	
	our $signtest_go_button  = $signtestWindow-> Button(-text=>"GO!", -foreground=>'green', -width=>40, -command=>\&signtestExecute) -> grid (-row=>20, -column=>1, -columnspan=>2, -pady=>20);
	
}

sub toolsCleanup{
	my $cleanupWindow =  $mw->Toplevel;
    $cleanupWindow->geometry("500x500");
    $cleanupWindow->title("Data Cleanup");

	#Widgets - Set up list of files
	our $cleanup_list_label = $cleanupWindow -> Label(-text => "Files containing occurrences:  ") -> grid(-row=>1, -column=>1, -pady=>5);
	our $cleanup_list_addbutton = $cleanupWindow -> Button(-text=>"Add files",-width=>20, -command=>\&cleanupAddFiles) -> grid(-row=>2, -column=>1, -padx=>5);
	our $cleanup_list_import = $cleanupWindow -> Button(-text=>"Import file list", -width=>20, -command=>\&cleanupImportList) -> grid(-row=>3, -column=>1, -padx=>5);
	our $cleanup_list_export = $cleanupWindow -> Button(-text=>"Save file list",-width=>20, -command=>\&cleanupExportList) -> grid(-row=>4, -column=>1, -padx=>5);
	our $cleanup_list_clear = $cleanupWindow -> Button(-text=>"Clear file list", -width=>20, -command=>\&cleanupClearFiles, -foreground=>'red') -> grid(-row=>5, -column=>1, -padx=>5);
	our $cleanup_files_frame = $cleanupWindow -> Frame();
	our $cleanup_files_list = $cleanup_files_frame -> Text(-width=>40, -height=>10);
	our $cleanup_files_scrollbar = $cleanup_files_frame -> Scrollbar(-orient=>'v',-command=>[yview => $cleanup_files_list]);
	$cleanup_files_list -> configure(-yscrollcommand=>['set', $cleanup_files_scrollbar]);
	$cleanup_files_list -> grid(-row=>1, -column=>1);
	$cleanup_files_frame -> grid(-row=>1, -column=>2, -rowspan=>5);
	$cleanup_files_scrollbar -> grid(-row=>1, -column=>2, -sticky=>"ns");
	
	#Widgets - cleanup options
	our $trimdupes = 1;
	our $trimduds = 1;
	our $cleanup_dupes_chk = $cleanupWindow -> Checkbutton(-text=>"Trim duplicate occurrences", -variable=>\$trimdupes) -> grid (-row=>6, -column=>1, -columnspan=>5, -pady=>5);
	our $cleanup_duds_chk = $cleanupWindow -> Checkbutton(-text=>"Trim occurrences with no environmental data", -variable=>\$trimduds) -> grid (-row=>7, -column=>1, -columnspan=>5, -pady=>5);
	
	#Widgets - cleanup GO button!
	our $cleanup_go_button = $cleanupWindow -> Button(-text=>"GO!", -foreground=>'green', -width=>40, -command=>\&cleanupExecute) -> grid (-row=>20, -column=>1, -columnspan=>5, -pady=>20);
}

sub toolsBatchProject{
	my $batchprojectWindow =  $mw->Toplevel;
    $batchprojectWindow->geometry("500x200");
    $batchprojectWindow->title("Batch Projection");
    
    our $batchproject_list_label = $batchprojectWindow -> Label(-text => "Lambda files:  ") -> grid(-row=>1, -column=>1, -pady=>5);
	our $batchproject_list_addbutton = $batchprojectWindow -> Button(-text=>"Add files",-width=>20, -command=>\&batchprojectAddFiles) -> grid(-row=>2, -column=>1, -padx=>5);
	our $batchproject_list_clear = $batchprojectWindow -> Button(-text=>"Clear file list", -width=>20, -command=>\&batchprojectClearFiles, -foreground=>'red') -> grid(-row=>3, -column=>1, -padx=>5);
	our $batchproject_files_frame = $batchprojectWindow -> Frame();
	our $batchproject_files_list = $batchproject_files_frame -> Text(-width=>40, -height=>5);
	our $batchproject_files_scrollbar = $batchproject_files_frame -> Scrollbar(-orient=>'v',-command=>[yview => $batchproject_files_list]);
	$batchproject_files_list -> configure(-yscrollcommand=>['set', $batchproject_files_scrollbar]);
	$batchproject_files_list -> grid(-row=>1, -column=>1);
	$batchproject_files_frame -> grid(-row=>1, -column=>2, -rowspan=>3, -pady=>10);
	$batchproject_files_scrollbar -> grid(-row=>1, -column=>2, -sticky=>"ns");
	
	#Widgets - cleanup GO button!
	our $batchproject_go_button = $batchprojectWindow -> Button(-text=>"GO!", -foreground=>'green', -width=>40, -command=>\&batchprojectExecute) -> grid (-row=>20, -column=>1, -columnspan=>5, -pady=>20);
	
}

#####Functions for use in the sign test window
sub signtestExecute{
	my $size1 = @signtest_files1;
	my $size2 = @signtest_files2;
	my @header = ();
	if($size1 != $size2){Tkx::tk___messageBox(-message=>"You must have an equal number of files in each set!");}
	else{  #Proceed with analysis
		my @countdiffs = (); #Will count the differences between files from arrays 1 and 2
		my $outfile = Tkx::tk___getSaveFile();
		for(my $i = 0; $i < $size1; $i++){
			open(ASCFILE1, "$signtest_files1[$i]");
			open(ASCFILE2, "$signtest_files2[$i]");
			my @ascfile1 = <ASCFILE1>;
			my @ascfile2 = <ASCFILE2>;
			close ASCFILE1;
			close ASCFILE2;
			for(my $j = 0; $j < @ascfile1; $j++){ #stepping through arrays line by line
				#$ascfile1[$j] =~ s/\r/\n/g;
				#$ascfile2[$j] =~ s/\r/\n/g;
				if((($ascfile1[$j] =~ /^\s*\d/) || ($ascfile1[$j] =~ /^\s*-/ )) && (($ascfile2[$j] =~ /^\s*\d/) || ($ascfile2[$j] =~ /^\s*-/ ))){
					my @thisline1 = split(/\s+/, $ascfile1[$j]);
					my @thisline2 = split(/\s+/, $ascfile2[$j]);					
					for(my $k = 0; $k < @thisline1; $k++){ #stepping through lines, entry by entry
						if($thisline1[$k]=~ /^-9999/ || $thisline2[$k]=~ /^-9999/ ){
							$countdiffs[$j][$k] = -9999;
						}
						else{
							my $addvalue;
							if($thisline1[$k] == $thisline2[$k]){$addvalue = 0;}
							if($thisline1[$k] > $thisline2[$k]){$addvalue = 1;}
							if($thisline1[$k] < $thisline2[$k]){$addvalue = -1;}
							$countdiffs[$j][$k] += $addvalue;
						}
					}
				}
				elsif($i == 0){
        			push(@header, $ascfile1[$j]);
        		}  
			}	
		}
		open(OUTFILE, ">$outfile");
		for(my $p = 0; $p < @header; $p++){
	       	print OUTFILE $header[$p];
		}
		for(my $m = @header; $m < @countdiffs; $m++){
			my $arrayref1 = @countdiffs[$m];
			my @outline = @$arrayref1;
			for(my $n = 0; $n < @outline; $n++){
				print OUTFILE "$outline[$n] ";
			}
			print OUTFILE "\n";
		}
		close OUTFILE;
		Tkx::tk___messageBox(-message=>"Sign test complete.\nResults saved to $outfile");
	}	   
}

sub signtestAddFiles1{
	my @thesefiles = Tkx::tk___getOpenFile(-multiple=>'set');
    for(@thesefiles){push (@signtest_files1, $_);}
    signtestUpdateFiles();
}


sub signtestClearFiles1{
	@signtest_files1 = ();
    $signtest_files_list1->Contents("");
}

sub signtestAddFiles2{
	my @thesefiles = Tkx::tk___getOpenFile(-multiple=>'set');
    for(@thesefiles){push (@signtest_files2, $_);}
    signtestUpdateFiles();
}

sub signtestClearFiles2{
	@signtest_files2 = ();
    $signtest_files_list2->Contents("");
}

sub signtestUpdateFiles {
    $signtest_files_list1->Contents("");
    my @shortnames1;
    for (@signtest_files1) {
        my @thisname = split(/\//, $_);
        push (@shortnames1, $thisname[-1]);
    }
    for (@shortnames1){
        $signtest_files_list1-> insert('end',"$_\n");
    }
    my $arraysize1 = @shortnames1;
    my $numcomps1 = $arraysize1*($arraysize1-1);
    $signtest_files_list2->Contents("");
    my @shortnames2;
    for (@signtest_files2) {
        my @thisname = split(/\//, $_);
        push (@shortnames2, $thisname[-1]);
    }
    for (@shortnames2){
        $signtest_files_list2-> insert('end',"$_\n");
    }
    my $arraysize2 = @shortnames2;
    my $numcomps2 = $arraysize2*($arraysize2-1);
#    $rangebreak_numcomparisons_label ->configure(-text=>"This will result in $numcomps comparisons") -> grid(-row=>6, -column=>1, -columnspan=>2, -pady=>20);
}


#####Functions for use in the batch project window
sub batchprojectAddFiles {
	my @thesefiles = Tkx::tk___getOpenFile(-multiple=>'set');
    for(@thesefiles){push (@batchproject_files, $_);}
    batchprojectUpdateFiles();
}

sub batchprojectUpdateFiles {
	$batchproject_files_list->Contents("");
    my @shortnames;
    for (@batchproject_files) {
        my @thisname = split(/\//, $_);
        push (@shortnames, $thisname[-1]);
    }
    for (@shortnames){
        $batchproject_files_list-> insert('end',"$_\n");
    }
    my $arraysize = @shortnames;
}

sub batchprojectClearFiles {
	@batchproject_files = ();
    $batchproject_files_list->Contents("");
}

sub batchprojectExecute {
	for(my $i = 0; $i < @batchproject_files; $i++){
		my @suffixline = split(/\//, $projectiondir);
		my @prefixline = split(/\//, $batchproject_files[$i]);
		my $outfile = $prefixline[-1];
		my $substitute = $suffixline[-1] . ".asc";
		$outfile =~ s/\.lambdas//;
		print "$outfile\n";
		$outfile = $output_directory . "\/" . $outfile . "_" . $substitute;
		#Tkx::tk___messageBox(-message=>"$outfile, $substitute, $suffixline[-1]");
		print "java -cp \"$maxent_path\" density.MaxEnt -e \"$projectiondir\" -s \"$batchproject_files[$i]\"  -o \"$outfile\"";
		system "java -cp \"$maxent_path\" density.MaxEnt -e \"$projectiondir\" -s \"$batchproject_files[$i]\"  -o \"$outfile\"";
	}
}

##### Functions for getting and setting options
sub getOptions{
    if(-e $configfile){
        open (CONFIG, "$configfile");
        while (<CONFIG>){
            my @thisline = split(/\s*=\s*/, $_);
            chomp($thisline[1]);
            $options{$thisline[0]} = $thisline[1];
        }
        $layers_type = $options{layers_type};
        $layers_path = $options{layers_path};
        $maxent_path = $options{maxent_path};
        $biasfile_path = $options{biasfile_path};
        $options_show_maxent = $options{options_show_maxent};
        if(!-e $maxent_path){Tkx::tk___messageBox(-message=>"Could not find maxent.jar at the specified location, please specify location in options tab.");}
        $suitability_type = $options{suitability_type};
        $output_directory = $options{output_directory};
        $projectiondir = $options{projection_directory};
        $jackboot_keepreps = $options{jackboot_keepreps}; 
		$rangebreak_keepreps = $options{rangebreak_keepreps};
		$identity_keepreps=$options{identity_keepreps};
		$background_keepreps=$options{background_keepreps};
		$pictures=$options{options_pictures};
		$rocplots=$options{options_rocplots};
		$responsecurves=$options{options_responsecurves};
		$memory=$options{options_memory};
		$options_maxent_version=$options{maxent_version};
		$removedupes = $options{removedupes};
		$maxent_beta = $options{maxent_beta};
		$large_overlap = $options{large_overlap};
		unless($memory){$memory = "-mx512m";}
		unless($maxent_beta){$maxent_beta = "1";}
        close CONFIG;
    }
    else {
        Tkx::tk___messageBox(-message=>"No config file found.");
    }
}

sub runScript{
	unless(-e $scriptfile){$scriptfile = Tkx::tk___getOpenFile();}
	open(SCRIPTFILE, "$scriptfile");
	$scripting = 1;
	while(<SCRIPTFILE>){
		chomp($_);
		print "$_ executing...\n";
		my @thisline = split(/,/,$_);
		if($thisline[0] =~ /measureoverlap/i){
			@overlap_files = ();
			push(@overlap_files, $thisline[1]);
			push(@overlap_files, $thisline[2]);
			$fileprefix = $thisline[3];
			overlapExecute();
		}
		if($thisline[0] =~ /identitytest/i){
			@identity_files = ();
			for(my $i = 1; $i < @thisline; $i++){
				if($thisline[$i] =~ /^nreps/i){
					$scripting_nreps = $thisline[$i];
					$scripting_nreps =~ s/nreps//gi;
					$scripting_nreps =~ s/\s*=\s*//gi;
					print "$scripting_nreps reps\n";
				}
				else{
					push(@identity_files, $thisline[$i]);
					print "$thisline[$i]\n";
				}
			}
			identityExecute();
		}
		if($thisline[0] =~ /backgroundtest/i){
			my %thisanalysis;
			$thisanalysis{'projectiondir'} = $projectiondir;
						
			for(my $i = 1; $i < @thisline; $i++){
				if($thisline[$i] =~ /^samplesfile/i){
					my $samplesfile = $thisline[$i];
					$samplesfile =~ s/samplesfile//gi;
					$samplesfile =~ s/\s*=\s*//gi;
					$thisanalysis{'samples'} = $samplesfile;
					print "Taking occurrences from $samplesfile\n";
				}
				if($thisline[$i] =~ /^backgroundfile/i){
					my $backgroundfile = $thisline[$i];
					$backgroundfile =~ s/backgroundfile//gi;
					$backgroundfile =~ s/\s*=\s*//gi;
					$thisanalysis{'background'} = $backgroundfile;
					print "Taking background from $backgroundfile\n";
				}
				if($thisline[$i] =~ /^nreps/i){
					$scripting_nreps = $thisline[$i];
					$scripting_nreps =~ s/nreps//gi;
					$scripting_nreps =~ s/\s*=\s*//gi;
					print "$scripting_nreps reps\n";
					$thisanalysis{'nreps'} = $scripting_nreps;
				}
				if($thisline[$i] =~ /^nback/i){
					$nback = $thisline[$i];
					$nback =~ s/nback//gi;
					$nback =~ s/\s*=\s*//gi;
					print "Using $nback background occurrences\n";
					$thisanalysis{'nback'} = $nback;
				}
			}
			push(@background_analyses, \%thisanalysis);
			backgroundExecute();
		}
		if($thisline[0]=~ /rastersample/i){
			@rastersample_files = ();
			for(my $i = 1; $i < @thisline; $i++){
				if($thisline[$i] =~ /^npoints/i){
					$scripting_npoints = $thisline[$i];
					$scripting_npoints =~ s/npoints//gi;
					$scripting_npoints =~ s/\s*=\s*//gi;
					print "$scripting_npoints points\n";
				}				
				elsif($thisline[$i] =~ /^nreps/i){
					$scripting_nreps = $thisline[$i];
					$scripting_nreps =~ s/nreps//gi;
					$scripting_nreps =~ s/\s*=\s*//gi;
					print "$scripting_nreps reps\n";				
				}
				elsif($thisline[$i] =~ /^functiontype/i){
					$rastersample_functiontype = $thisline[$i];
					$rastersample_functiontype =~ s/functiontype//gi;
					$rastersample_functiontype =~ s/\s*=\s*//gi;
					print "Probability of occurrence is a $rastersample_functiontype function of raster scores.\n";
				}
				else{
					push(@rastersample_files, $thisline[$i]);
					print "$thisline[$i]\n";
				}
			}
			#for(my $k = 0; $k < @rastersample_files; $k++){print $rastersample_files[$k];}
			rastersampleExecute();
		}
		if($thisline[0] =~ /options/i){
			for(my $i = 1; $i < @thisline; $i++){
				if($thisline[$i] =~ /^setbeta/i){
					$maxent_beta = $thisline[$i];
					$maxent_beta =~ s/\s*setbeta\s*=\s*//gi;
					print "Setting beta to $maxent_beta\n";
				}
				if($thisline[$i] =~ /^setoutdir/i){
					$output_directory = $thisline[$i];
					$output_directory =~ s/\s*setoutdir\s*=\s*//gi;
					print "Setting output directory to $output_directory\n";
				}				
			}
		}

	}
	close SCRIPTFILE;
	$scripting = 0;
	print "Execution of script file $scriptfile complete.\n";
	$scriptfile = "";
}

sub setLayersDir {
	if($layers_type eq "Layers directory"){$layers_path = Tkx::tk___chooseDirectory();}
	if($layers_type eq "CSV file"){$layers_path = Tkx::tk___getOpenFile();}
}

sub setMaxentPath {
    $maxent_path = Tkx::tk___getOpenFile(-initialfile=>"");   
}


sub setBiasfilePath {
    $biasfile_path = Tkx::tk___getOpenFile(-initialfile=>"");   
}

sub optionsOutputDir{
    $output_directory = Tkx::tk___chooseDirectory();
}

sub optionsProjectionDir{
	$projectiondir = Tkx::tk___chooseDirectory();
}

sub saveConfig {
    open(CONFIG, ">enmtools.config");
    print CONFIG "layers_path = $layers_path
maxent_path = $maxent_path
biasfile_path = $biasfile_path
maxent_beta = $maxent_beta
suitability_type = $suitability_type
options_show_maxent = $options_show_maxent
output_directory = $output_directory
projection_directory = $projectiondir
layers_type = $layers_type
jackboot_keepreps = $jackboot_keepreps
rangebreak_keepreps = $rangebreak_keepreps
identity_keepreps = $identity_keepreps
background_keepreps = $background_keepreps
options_memory = $memory
options_pictures = $pictures
options_responsecurves = $responsecurves
options_rocplots = $rocplots
removedupes = $removedupes
large_overlap = $large_overlap
maxent_version = $options_maxent_version";

    close CONFIG;
    Tkx::tk___messageBox(-message=>"Options saved to enmtools.config");
}

##### Miscellaneous tools
sub log2 {
    my $n = shift;
    return log($n)/log(2);
}

sub sqr {
$_[0] * $_[0];
}

sub regression{
	my $file1name = shift;
	my $file2name = shift;
	open(FILE1, "$file1name") || die "Can't open $file1name!\n";
	open(FILE2, "$file2name") || die "Can't open $file2name!\n";
	my @file1 = <FILE1>;
	my @file2 = <FILE2>;
	close FILE1, FILE2;
	
	
	
	my $sumx = 0, $sumx2 = 0, $sumxy = 0, $sumy = 0, $sumy2 = 0, $n = 0;
	
	for(my $k = 0; $k < @file1; $k++){   #####  Cycle through to get sum for all point probabilities in each file  #####
		#$file1[$k] =~ s/\r/\n/g;
		#$file2[$k] =~ s/\r/\n/g;
		if((($file1[$k] =~ /^\s*\d/ ) || ($file1[$k] =~ /^\s*-/ ) ) && (($file2[$k] =~ /^\s*\d/ )|| ($file2[$k] =~ /^\s*-/ ))){
        	my @file1line = split(/\s+/, $file1[$k]);
            my @file2line = split(/\s+/, $file2[$k]);
            for(my $l = 0; $l < @file1line; $l++){
            	if($file1line[$l] ne "-9999" && $file2line[$l] ne "-9999"){
					my $x = $file2line[$l];
					my $y = $file1line[$l];
					$n++;                                             
   					$sumx  += $x;                                               
				    $sumx2 += $x * $x;                                      
   					$sumxy += $x * $y;                                   
   					$sumy  += $y;   
   					$sumy2 += $y * $y;                                                             
               	}
           	}
		}
  }
  print "$n\t$sumx2\t$sumx\n";
  my $slope = ($n * $sumxy  -  $sumx * $sumy) / ($n * $sumx2 - sqr($sumx));                
	my $intercept = ($sumy * $sumx2  -  $sumx * $sumxy) / ($n * $sumx2  -  ($sumx * $sumx));  
	my $r = ($sumxy - $sumx * $sumy / $n) / sqrt(($sumx2 - sqr($sumx)/$n) * ($sumy2 - sqr($sumy)/$n));
    
  my $meanx = ($sumx/($n + 1));
  my $meany = ($sumy/($n + 1));
  print "Slope is $slope, intercept is $intercept, R is $r.\n";
  if($corr_make_residuals){
    my $prefix = $file1name;
    $prefix =~ s/.asc$/_/;
    my @thisname = split(/\//, $file2name);
    my $suffix = $thisname[-1];
    
    my $outfilename = $prefix . $suffix;
    print "Printing residuals to $outfilename\n";
    open(RESIDUALS, ">$outfilename");
    open(FILE1, "$file1name") || die "Can't open $file1name!\n";
    open(FILE2, "$file2name") || die "Can't open $file2name!\n";
    my @file1 = <FILE1>;
    my @file2 = <FILE2>;
    close FILE1, FILE2;
    
    
    for(my $k = 0; $k < @file1; $k++){   #####  Cycle through to get sum for all point probabilities in each file  #####
    	#$file1[$k] =~ s/\r/\n/g;
    	#$file2[$k] =~ s/\r/\n/g;
      if((($file1[$k] =~ /^\s*\d/ ) || ($file1[$k] =~ /^\s*-/ ) ) && (($file2[$k] =~ /^\s*\d/ )|| ($file2[$k] =~ /^\s*-/ ))){
        my @file1line = split(/\s+/, $file1[$k]);
        my @file2line = split(/\s+/, $file2[$k]);
        for(my $l = 0; $l < @file1line; $l++){
          if($file1line[$l] ne "-9999" && $file2line[$l] ne "-9999"){
            my $x = $file2line[$l];
            my $y = $file1line[$l];
            my $residual = $y - (($slope * $x) + $intercept);
            print RESIDUALS "$residual ";
          }
          else{print RESIDUALS "-9999 ";}
       	}
       	print RESIDUALS "\n";
      }
      else{print RESIDUALS $file1[$k];} #Header line
    }
    
    close RESIDUALS;
  }
  return ($slope, $intercept, $r);
}

sub fisher_yates_shuffle {
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}

sub maskToPoints{
	print "in maskToPoints\n";
	 # Function accepts a file name (the mask file), and returns
     # an array of occurrence points, one for each cell that doesn't
     # contain a nodata value
     
     # Steps through background file, gets file parameters
     my @data;
     my @backgroundpoints;
     my %fileparams;
     my $maskfile = shift;
     open (MASKFILE, $maskfile)                                    ||die "Couldn't open $maskfile!";
     while(<MASKFILE>){
          if($_=~ /^\s*[0123456789-]/){
               chomp($_);
               unshift(@data, $_);
          }
          else{ # Distinguishes file parameters from data
               my @thisline = split(/\s+/, $_);
               $fileparams{lc($thisline[0])} = $thisline[1]; #Keys are being converted to all lower case!
          }
     }
     my $xll = $fileparams{xllcorner};
     my $yll = $fileparams{yllcorner};
     my $cellsize = $fileparams{cellsize};
     my $nodata = $fileparams{nodata_value};
     my $nrows = @data;
     for(my $i=0; $i< @data; $i++){
          my @thisline = split(/\s+/, $data[$i]);
          for(my $j = 0; $j < @thisline; $j++){
               if($thisline[$j] != $nodata){
                    my $thispointx = $xll + ($j * $cellsize) + ($cellsize/2); 
                    my $thispointy = $yll + ($i * $cellsize) + ($cellsize/2);
                    my $thispoint = $thispointx . "," . $thispointy;
                    push(@backgroundpoints, $thispoint);
               }
          }
     }
     return @backgroundpoints;
}

sub csvToArray{
	print "in csvToArray\n";
	# Takes a csv file and returns an array of XY values
	my $infile = shift;
	open(INFILE, "$infile");
	my @thisarray = <INFILE>;
	close INFILE;
	my @backgroundpoints;
	#$thisarray[0] =~ s/\r/\n/g;
	for(my $i = 1; $i < @thisarray; $i++){ #Starting at 1 to skip header line
		#$thisarray[$i] =~ s/\r/\n/g;
		chomp $thisarray[$i];
		my @thisline = split(/,/ , $thisarray[$i]);
		my $thispoint = $thisline[1];
		for(my $j = 2; $j < @thisline; $j++){
			$thispoint = $thispoint . "," . $thisline[$j];	
		}
		push(@backgroundpoints, $thispoint);
		#print "$thispoint\n";
	}
	return @backgroundpoints;
}

sub isSWD{  #This function just takes a path to a csv file and returns 1 if swd, 0 if not
	my $infile = shift;
	open(INFILE, "$infile");
	my @thisarray = <INFILE>;
	close INFILE;
	my @thisline = split(/,/, $thisarray[0]);
	my $arraysize = @thisline;
	my $returnvalue;
	if($arraysize > 3){$returnvalue = 1;}
	else{$returnvalue = 0;}
	return $returnvalue;
}


sub threshold{
	#takes an ASCII GIS raster file containing
	#a continuous variable and converts it to a binary (yes/no) ASCII
	#file.  This is done with a specified threshold, so that the resulting
	#file contains presences for all points over the specified threshold in the
	#original distribution.  For instance, if one were to invoke the script on a
	#cumulative Maxent output file and a threshold of 50, the points where Maxent
	#predicted a cumulative suitability over 50 would be given values of 1, while
	#the rest would be given 0.
	my $threshold_infile = shift;
	my $threshold_outfile = shift;
	my $threshold = shift;
	print "THRESHOLD got $threshold_infile, $threshold_outfile, $threshold\n";
	my $ready_to_go = 1;
	if(!-e $threshold_infile){
		print "Can't find $threshold_infile in threshold subroutine";
		$ready_to_go = 0;
	}
	unless($threshold =~ /\d+E*\d*/){
		$ready_to_go = 0;
	}
		
	open(THRESHOLD_INFILE, "$threshold_infile") or die "Can't open $threshold_infile!";
	my @threshold_infile = <THRESHOLD_INFILE>;
	
	#### Open infile, open outfile, and create ASCII file with 1 everywhere above the cutoff, 0 everywhere else ####
	my $prefix = $threshold_infile;
	$prefix =~ s/\.asc//;
	
	print "Creating $threshold_outfile.\n";
	open(THRESHOLD_OUTFILE, ">$threshold_outfile") or die "Can't create output file!\n";
	for(my $k = 0; $k < @threshold_infile; $k++){   
		#$threshold_infile[$k] =~ s/\r/\n/g;
	    if(($threshold_infile[$k] =~ /^\s*\d/ ) || ($threshold_infile[$k] =~ /^\s*-/ ) ) {
	        chomp($threshold_infile[$k]);
	        my @line1 = split(/\s+/, $threshold_infile[$k]);
	        for(my $l = 0; $l < @line1; $l++){
	            if($line1[$l] ne "-9999"){
	                if($line1[$l] < $threshold){print THRESHOLD_OUTFILE "0 ";}
	                if($line1[$l] >= $threshold){print THRESHOLD_OUTFILE "1 ";}
	            }
	            else{print THRESHOLD_OUTFILE "$line1[$l] ";}
	        }
	        print THRESHOLD_OUTFILE "\n";
	    }
	    else{print THRESHOLD_OUTFILE "$threshold_infile[$k]";}  #### Print lines without data as is ####
	}
	close THRESHOLD_OUTFILE;
}

Tkx::MainLoop();
