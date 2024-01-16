CREATE OR REPLACE package WEBSYS.lng3
as

--
-- English Language Module #3
--
-- This Module is required as there is a 64K limit for a package header
--
-- Note to the Translator:
-- 1. Only translate the right hand side value contained between ''. eg. '$999,990.99'
-- 2. Special translation notes are included before each value
-- 3. Ensure the translated value does not contain a ' value inside it. If it does, then replace it by '', eg. 'abcd'e'; --> 'abcd''e';
-- 4. If a line starts with -- (Not used), or -- (Dupl) then ignore it. It will disappear in a later version.
--    The -- (Not used) indicates that no program references this value anymore
--    The -- (Dupl) indicates that this value is already used and is redundant.
-- 5. The value of the left hand side (eg. GLB_TXT_001 ), is what is referenced in the program, so do not change it.
--    The values do hot have to appear sequentially, so don't worry if they are out of sequence.
--
-- General Variables
--


--
-- ADM
--

ADM_DATE_01	constant varchar2(200)		:=  'DD Mon YYYY HH24:MI';
ADM_DATE_02	constant varchar2(200)		:=  'DD-MON-YYYY';
ADM_DATE_03	constant varchar2(200)		:=  '999,999.99';


ADM_TXT_001	constant varchar2(200)		:=  'Testing Data Entry';
ADM_TXT_002	constant varchar2(200)		:=  'Enter in Data';
ADM_TXT_003	constant varchar2(200)		:=  'Test Field2';
ADM_TXT_005	constant varchar2(200)		:=  'Submit Button';
ADM_TXT_006	constant varchar2(200)		:=  'End Test Page';
ADM_TXT_007	constant varchar2(200)		:=  'Choose an Option from the Menu Bar';
ADM_TXT_008	constant varchar2(200)		:=  'Charge Plans';
ADM_TXT_009	constant varchar2(200)		:=  'Choose a Charge Plan to Modify it or Create New Charge Plan';
ADM_TXT_010	constant varchar2(200)		:=  'Create a Customer Account for the Client';

ADM_TXT_011	constant varchar2(200)		:=  'Job Already Exists on the Queue';
ADM_TXT_012	constant varchar2(200)		:=  'Master Details Successfully Updated';
ADM_TXT_013	constant varchar2(200)		:=  'Modify Master Details';
ADM_TXT_020	constant varchar2(200)		:=  'Admin Password';

ADM_TXT_035	constant varchar2(200)		:=  'Job Submitted';
ADM_TXT_036	constant varchar2(200)		:=  'Choose the Load Method from one of the following Customers';
ADM_TXT_037	constant varchar2(200)		:=  'Job Deleted';
ADM_TXT_038	constant varchar2(200)		:=  'Expired Accounts';
ADM_TXT_039	constant varchar2(200)		:=  'Job Not Found';
ADM_TXT_040	constant varchar2(200)		:=  'Connect As';

ADM_TXT_041	constant varchar2(200)		:=  'Extract Slide Show';
ADM_TXT_042	constant varchar2(200)		:=  'Bulk Image Load';
ADM_TXT_043	constant varchar2(200)		:=  'Redirect Login';
ADM_TXT_044	constant varchar2(200)		:=  'Forms';
ADM_TXT_045	constant varchar2(200)		:=  'WARNING !!!';
ADM_TXT_046	constant varchar2(200)		:=  'This will delete the Client, all Client Customer Accounts but not the Purchase Requests for this Client.';
ADM_TXT_047	constant varchar2(200)		:=  'Are You Sure?';
ADM_TXT_048	constant varchar2(200)		:=  'Type in the Word DELETE in the text field below to confirm deletion of this account';
ADM_TXT_049	constant varchar2(200)		:=  'DELETE CLIENT';
ADM_TXT_050	constant varchar2(200)		:=  'This will delete the Manufacturer and all associated details.';

ADM_TXT_051	constant varchar2(200)		:=  'DELETE Manufacturer';
ADM_TXT_052	constant varchar2(200)		:=  'Client not deleted.';
ADM_TXT_053	constant varchar2(200)		:=  'Client has been completely deleted.';
ADM_TXT_054	constant varchar2(200)		:=  'Manufacturer not deleted.';
ADM_TXT_055	constant varchar2(200)		:=  'Manufacturer has been completely deleted.';
ADM_TXT_056	constant varchar2(200)		:=  'Delete Client';
ADM_TXT_057	constant varchar2(200)		:=  'Client Details Successfully Modified';
ADM_TXT_058	constant varchar2(200)		:=  'Delete Manufacturer';
ADM_TXT_059	constant varchar2(200)		:=  'Manufacturer Details Successfully Modified';
ADM_TXT_060	constant varchar2(200)		:=  'Enter in new Client Details';

ADM_TXT_061	constant varchar2(200)		:=  'Client Details';
ADM_TXT_062	constant varchar2(200)		:=  'Cull errors if they are older in days than';
ADM_TXT_063	constant varchar2(200)		:=  'User Name';
ADM_TXT_064	constant varchar2(200)		:=  'Extra';
ADM_TXT_065	constant varchar2(200)		:=  'Broken';
ADM_TXT_066	constant varchar2(200)		:=  'Lab Account Id';
ADM_TXT_067	constant varchar2(200)		:=  'Manufacturer Discount %';
ADM_TXT_068	constant varchar2(200)		:=  'Credit Card Handling Fee %';
ADM_TXT_070	constant varchar2(200)		:=  'Forum Enabled';

ADM_TXT_071	constant varchar2(200)		:=  'Forum Privileges';
ADM_TXT_072	constant varchar2(200)		:=  'Failures';
ADM_TXT_073	constant varchar2(200)		:=  'Limit Business Features';
ADM_TXT_074	constant varchar2(200)		:=  'All Business Features';
ADM_TXT_075	constant varchar2(200)		:=  'Manage Monitoring Job';
ADM_TXT_076	constant varchar2(200)		:=  'Limit Categories';
ADM_TXT_078	constant varchar2(200)		:=  'Batch Job Status';
ADM_TXT_079	constant varchar2(200)		:=  'Limit Look and Feel';
ADM_TXT_080	constant varchar2(200)		:=  'All Look and Feels';

ADM_TXT_081	constant varchar2(200)		:=  'Limit Look and Feels';
ADM_TXT_082	constant varchar2(200)		:=  'Insert New Client';
ADM_TXT_083	constant varchar2(200)		:=  'Modify Client';
ADM_TXT_084	constant varchar2(200)		:=  'Enter in new Manufacturer Details';
ADM_TXT_086	constant varchar2(200)		:=  'Manufacturer Type';
ADM_TXT_087	constant varchar2(200)		:=  'Job Parameters';
ADM_TXT_088	constant varchar2(200)		:=  'Look and Feel';
ADM_TXT_089	constant varchar2(200)		:=  'Insert Manufacturer';
ADM_TXT_090	constant varchar2(200)		:=  'Modify Manufacturer';

ADM_TXT_091	constant varchar2(200)		:=  'Error';
ADM_TXT_092	constant varchar2(200)		:=  'New Plan';
ADM_TXT_093	constant varchar2(200)		:=  'List Expired Accounts';
ADM_TXT_094	constant varchar2(200)		:=  'Listing of all Client Accounts that have expired';
ADM_TXT_095	constant varchar2(200)		:=  'Optimisation Parameters';
ADM_TXT_096	constant varchar2(200)		:=  'Date Expired';
ADM_TXT_097	constant varchar2(200)		:=  'No Expired Accounts Exist';
ADM_TXT_098	constant varchar2(200)		:=  'Charge Plan Management';
ADM_TXT_099	constant varchar2(200)		:=  'Charge Plan Name';
ADM_TXT_100	constant varchar2(200)		:=  'Payment Style';

ADM_TXT_101	constant varchar2(200)		:=  'Payment Target';
ADM_TXT_102	constant varchar2(200)		:=  'Owner Plan';
ADM_TXT_103	constant varchar2(200)		:=  'Customer Plan';
ADM_TXT_104	constant varchar2(200)		:=  'Renewal Date DD/MM';
ADM_TXT_105	constant varchar2(200)		:=  'Description';
ADM_TXT_106	constant varchar2(200)		:=  'Plan Charge $$$';
ADM_TXT_107	constant varchar2(200)		:=  'Start Batch Manager';
ADM_TXT_108	constant varchar2(200)		:=  'Max Accounts';
ADM_TXT_109	constant varchar2(200)		:=  'Max Photos';
ADM_TXT_110	constant varchar2(200)		:=  'Max Photos Size (Kb)';

ADM_TXT_111	constant varchar2(200)		:=  'Days until Account Expires';
ADM_TXT_112	constant varchar2(200)		:=  'Create New Charge Plan';
ADM_TXT_113	constant varchar2(200)		:=  'Modify Charge Plan';
ADM_TXT_114	constant varchar2(200)		:=  'Delete Charge Plan';
ADM_TXT_115	constant varchar2(200)		:=  'Cross Reference Report of Clients';
ADM_TXT_116	constant varchar2(200)		:=  'Cannot Delete Plan.';
ADM_TXT_117	constant varchar2(200)		:=  'client(s) are using it.';
ADM_TXT_118	constant varchar2(200)		:=  'Charge Plan Deleted. Please Enter in a new Charge Plan';
ADM_TXT_119	constant varchar2(200)		:=  'You must enter in a Plan Name';
ADM_TXT_120	constant varchar2(200)		:=  'Charge Plan Modification Successful';

ADM_TXT_121	constant varchar2(200)		:=  'Options for Manufacturers';
ADM_TXT_122	constant varchar2(200)		:=  'Map Types to Products';
ADM_TXT_123	constant varchar2(200)		:=  'Product Categories';
ADM_TXT_124	constant varchar2(200)		:=  'Map Lab Theme/Film';
ADM_TXT_125	constant varchar2(200)		:=  'Lab Film Sizes';
ADM_TXT_126	constant varchar2(200)		:=  'Match Line of Business to a Type of Product';
ADM_TXT_127	constant varchar2(200)		:=  'Business';
ADM_TXT_128	constant varchar2(200)		:=  'Stop Batch Manager';
ADM_TXT_130	constant varchar2(200)		:=  'Film Sizes';

ADM_TXT_131	constant varchar2(200)		:=  'Film Size Description';
ADM_TXT_132	constant varchar2(200)		:=  'Modify Film Sizes';
ADM_TXT_133	constant varchar2(200)		:=  'Quick Connect to a Client and or their Account';
ADM_TXT_134	constant varchar2(200)		:=  'Phy Wrts';
ADM_TXT_135	constant varchar2(200)		:=  'Customer Account Owner';
ADM_TXT_136	constant varchar2(200)		:=  'Customer Account Guest';
ADM_TXT_137	constant varchar2(200)		:=  'Phy Rds';
ADM_TXT_138	constant varchar2(200)		:=  'Trapped Errors';
ADM_TXT_139	constant varchar2(200)		:=  'Package';
ADM_TXT_140	constant varchar2(200)		:=  'Map Existing Laboratory Forms to a Manufacturer';

ADM_TXT_141	constant varchar2(200)		:=  'Form Name';
ADM_TXT_142	constant varchar2(200)		:=  'Map Forms to a Manufacturer';
ADM_TXT_143	constant varchar2(200)		:=  'Piction Administration: Choose a Client';
ADM_TXT_144	constant varchar2(200)		:=  'Create New Client';
ADM_TXT_145	constant varchar2(200)		:=  'Force Storage Report';
ADM_TXT_146	constant varchar2(200)		:=  'Type of Manufacturer';
ADM_TXT_147	constant varchar2(200)		:=  'Product Price Book Name';
ADM_TXT_148	constant varchar2(200)		:=  'Add/Update Manufacturer Options';
ADM_TXT_149	constant varchar2(200)		:=  'Edit Manufacturer Product Categories';
ADM_TXT_150	constant varchar2(200)		:=  'Mfct Type';

ADM_TXT_152	constant varchar2(200)		:=  'Part of';
ADM_TXT_153	constant varchar2(200)		:=  'Add/Update Type of Products';
ADM_TXT_154	constant varchar2(200)		:=  'Choose a Manufacturer';
ADM_TXT_155	constant varchar2(200)		:=  'Create New Manufacturer';
ADM_TXT_156	constant varchar2(200)		:=  'Procedure';
ADM_TXT_157	constant varchar2(200)		:=  'Your Session has been disconnected';
ADM_TXT_158	constant varchar2(200)		:=  'Administration Login Page';
ADM_TXT_159	constant varchar2(200)		:=  'Customer Login Page';
ADM_TXT_160	constant varchar2(200)		:=  'Choose Connection Option';

ADM_TXT_161	constant varchar2(200)		:=  'Administrator password has been reset back to the default value.';
ADM_TXT_162	constant varchar2(200)		:=  'You must provide a username for the client';
ADM_TXT_163	constant varchar2(200)		:=  'Password cannot be empty';
ADM_TXT_164	constant varchar2(200)		:=  'Customer account with this name already exists';
ADM_TXT_165	constant varchar2(200)		:=  'Client account with this name already exists';
ADM_TXT_166	constant varchar2(200)		:=  'Manufacturer account with this name already exists';
ADM_TXT_167	constant varchar2(200)		:=  'Block Size';
ADM_TXT_168	constant varchar2(200)		:=  'Insert New Category';
ADM_TXT_169	constant varchar2(200)		:=  'New Category';
ADM_TXT_170	constant varchar2(200)		:=  'Manage Category';

ADM_TXT_171	constant varchar2(200)		:=  'PUBLIC Category Details';
ADM_TXT_172	constant varchar2(200)		:=  'Force Optimisation';
ADM_TXT_173	constant varchar2(200)		:=  'Image Gif';
ADM_TXT_174	constant varchar2(200)		:=  'Title Gif';
ADM_TXT_175	constant varchar2(200)		:=  'Chained Rows';
ADM_TXT_176	constant varchar2(200)		:=  'Titles in the Category';
ADM_TXT_177	constant varchar2(200)		:=  'Display Order';
ADM_TXT_178	constant varchar2(200)		:=  'Chained Rows Report';
ADM_TXT_179	constant varchar2(200)		:=  'Client Private Categories';
ADM_TXT_180	constant varchar2(200)		:=  'Modify Category Details';

ADM_TXT_181	constant varchar2(200)		:=  'XML Download to file';
ADM_TXT_182	constant varchar2(200)		:=  'Download This Category';
ADM_TXT_183	constant varchar2(200)		:=  'The Category must have a name';
ADM_TXT_184	constant varchar2(200)		:=  'Category Details Successfully Updated';
ADM_TXT_185	constant varchar2(200)		:=  'Modify Look and Feel Types';
ADM_TXT_186	constant varchar2(200)		:=  'Insert Look and Feel Type';
ADM_TXT_187	constant varchar2(200)		:=  'New Look and Feel';
ADM_TXT_188	constant varchar2(200)		:=  'Manage Look and Feel Type';
ADM_TXT_189	constant varchar2(200)		:=  'Forcing Optimisation';
ADM_TXT_190	constant varchar2(200)		:=  'Class';

ADM_TXT_191	constant varchar2(200)		:=  'Prefix';
ADM_TXT_192	constant varchar2(200)		:=  'Button Style and Location';
ADM_TXT_193	constant varchar2(200)		:=  'Left/Right Frame';
ADM_TXT_194	constant varchar2(200)		:=  'Top Frame';
ADM_TXT_195	constant varchar2(200)		:=  'Left/Right Frame Duplicated';
ADM_TXT_196	constant varchar2(200)		:=  'Uses Boundary Markers around Buttons';
ADM_TXT_197	constant varchar2(200)		:=  'Hover Colour';
ADM_TXT_198	constant varchar2(200)		:=  'Title Bar Page Text Font';
ADM_TXT_199	constant varchar2(200)		:=  'Title Bar Font Colour';
ADM_TXT_200	constant varchar2(200)		:=  'Title Bar Colour';

ADM_TXT_201	constant varchar2(200)		:=  'Standard Text Font';
ADM_TXT_202	constant varchar2(200)		:=  'Standard Text Colour';
ADM_TXT_203	constant varchar2(200)		:=  'Standard Background Colour';
ADM_TXT_204	constant varchar2(200)		:=  'LHS Text Font';
ADM_TXT_205	constant varchar2(200)		:=  'LHS Text Colour';
ADM_TXT_206	constant varchar2(200)		:=  'LHS Background Colour';
ADM_TXT_207	constant varchar2(200)		:=  'Home Page Title Font';
ADM_TXT_208	constant varchar2(200)		:=  'Home Page Title Font Colour';
ADM_TXT_209	constant varchar2(200)		:=  'Home Page Cell Colour (either side of Image)';
ADM_TXT_210	constant varchar2(200)		:=  'Home Page Text Font';

ADM_TXT_211	constant varchar2(200)		:=  'Home Page Text Colour';
ADM_TXT_212	constant varchar2(200)		:=  'Home Page Background Colour';
ADM_TXT_213	constant varchar2(200)		:=  'Customer Top Bar Text Font';
ADM_TXT_214	constant varchar2(200)		:=  'Customer Top Bar Text Colour';
ADM_TXT_215	constant varchar2(200)		:=  'Customer Top Bar Background Colour';
ADM_TXT_216	constant varchar2(200)		:=  'Gallery Text Font';
ADM_TXT_217	constant varchar2(200)		:=  'Gallery Text Colour';
ADM_TXT_218	constant varchar2(200)		:=  'Gallery Background Colour';
ADM_TXT_219	constant varchar2(200)		:=  'Frame Border Width';
ADM_TXT_220	constant varchar2(200)		:=  'Border around Category Width';

ADM_TXT_221	constant varchar2(200)		:=  'Modify Look and Feel Details';
ADM_TXT_222	constant varchar2(200)		:=  'Delete Look and Feel';
ADM_TXT_224	constant varchar2(200)		:=  '# Rows';
ADM_TXT_225	constant varchar2(200)		:=  'Download This Look and Feel';
ADM_TXT_226	constant varchar2(200)		:=  'The Theme must have a name';
ADM_TXT_228	constant varchar2(200)		:=  'Look and Feel has been Deleted';
ADM_TXT_229	constant varchar2(200)		:=  'Details Successfully Updated';
ADM_TXT_230	constant varchar2(200)		:=  'The following icons are used by CLIENTS and CUSTOMERS';

ADM_TXT_231	constant varchar2(200)		:=  'All icons follow a standard of a defined prefix and a fixed suffix. The suffix is hard coded into the program.';
ADM_TXT_232	constant varchar2(200)		:=  'Most icons are changed when mouse_over. The mouse_over image has an x as the last file name character.';
ADM_TXT_233	constant varchar2(200)		:=  'Listed below are all icons gifs and their mouse_over gifs. The prefix is specified in the theme.';
ADM_TXT_235	constant varchar2(200)		:=  'Greeting Card';
ADM_TXT_236	constant varchar2(200)		:=  '# Blocks';
ADM_TXT_237	constant varchar2(200)		:=  'Manage Customer Default Preferences';
ADM_TXT_238	constant varchar2(200)		:=  'Type';
ADM_TXT_239	constant varchar2(200)		:=  'Forcing Storage Report';

ADM_TXT_241	constant varchar2(200)		:=  'Modify Default Customer Preferences';
ADM_TXT_242	constant varchar2(200)		:=  'Preferences Successfully Updated';
ADM_TXT_243	constant varchar2(200)		:=  'Connection Statistics';
ADM_TXT_244	constant varchar2(200)		:=  'Currently Connected';
ADM_TXT_245	constant varchar2(200)		:=  'Report Forced';
ADM_TXT_246	constant varchar2(200)		:=  'Connection Type';
ADM_TXT_248	constant varchar2(200)		:=  'Avg # Web Calls';
ADM_TXT_249	constant varchar2(200)		:=  'Avg Time Connected for (minutes)';
ADM_TXT_250	constant varchar2(200)		:=  'Yearly Statistics by Client and Account (connections/hits)';

ADM_TXT_251	constant varchar2(200)		:=  'General Report';
ADM_TXT_252	constant varchar2(200)		:=  'Storage Report';
ADM_TXT_253	constant varchar2(200)		:=  'Disconnect Elapsed Sessions';
ADM_TXT_254	constant varchar2(200)		:=  'Note: This is automatically done, but can be manually performed';
ADM_TXT_255	constant varchar2(200)		:=  'Disconnect';
ADM_TXT_256	constant varchar2(200)		:=  'Disconnect All Sessions';
ADM_TXT_257	constant varchar2(200)		:=  'Note: This is only to be done for maintenance purposes';
ADM_TXT_258	constant varchar2(200)		:=  'Disconnect All';
ADM_TXT_259	constant varchar2(200)		:=  'Connection Graph';
ADM_TXT_260	constant varchar2(200)		:=  'Time Period';

ADM_TXT_261	constant varchar2(200)		:=  'Client';
ADM_TXT_262	constant varchar2(200)		:=  'Time From';
ADM_TXT_263	constant varchar2(200)		:=  'Time To';
ADM_TXT_264	constant varchar2(200)		:=  'Drill Date';
ADM_TXT_265	constant varchar2(200)		:=  'Drill Client';
ADM_TXT_266	constant varchar2(200)		:=  'Period (Date/Account)';
ADM_TXT_267	constant varchar2(200)		:=  'Security Report';
ADM_TXT_269	constant varchar2(200)		:=  'Bar Chart (per 1000)';
ADM_TXT_270	constant varchar2(200)		:=  'All Sessions Disconnected';

ADM_TXT_271	constant varchar2(200)		:=  'Elapsed Sessions Disconnected';
ADM_TXT_272	constant varchar2(200)		:=  'Generating Cost Statistics';
ADM_TXT_273	constant varchar2(200)		:=  'Generating for';
ADM_TXT_274	constant varchar2(200)		:=  'Press to Confirm Deletion of this Health Check' ;
ADM_TXT_275	constant varchar2(200)		:=  'Oracle Table Statistics';
ADM_TXT_276	constant varchar2(200)		:=  'Current Piction Version';
ADM_TXT_277	constant varchar2(200)		:=  'Summary of Object Usage';
ADM_TXT_278	constant varchar2(200)		:=  'Segment Type';
ADM_TXT_279	constant varchar2(200)		:=  'Sum Bytes';
ADM_TXT_280	constant varchar2(200)		:=  'Sum Blocks';

ADM_TXT_281	constant varchar2(200)		:=  'Max Extent';
ADM_TXT_282	constant varchar2(200)		:=  'Tablespace';
ADM_TXT_283	constant varchar2(200)		:=  'Piction Alert Log Report';
ADM_TXT_284	constant varchar2(200)		:=  'Max Bytes';
ADM_TXT_285	constant varchar2(200)		:=  'Delete Database Health Check';
ADM_TXT_286	constant varchar2(200)		:=  'Max Blocks';
ADM_TXT_287	constant varchar2(200)		:=  'Summary of Free Space';
ADM_TXT_288	constant varchar2(200)		:=  'Object Details';
ADM_TXT_289	constant varchar2(200)		:=  'Bytes';
ADM_TXT_290	constant varchar2(200)		:=  'Blocks';

ADM_TXT_291	constant varchar2(200)		:=  'Extents';
ADM_TXT_292	constant varchar2(200)		:=  'Initial';
ADM_TXT_293	constant varchar2(200)		:=  'Confirm Delete of Database Health Check';
ADM_TXT_294	constant varchar2(200)		:=  'Max Extents';
ADM_TXT_295	constant varchar2(200)		:=  'Cost Statistics Tables';
ADM_TXT_296	constant varchar2(200)		:=  'Table Name';
ADM_TXT_297	constant varchar2(200)		:=  'Num Rows';
ADM_TXT_298	constant varchar2(200)		:=  'Empty Blocks';
ADM_TXT_299	constant varchar2(200)		:=  'Avg Space';
ADM_TXT_300	constant varchar2(200)		:=  'Chain Cnt';

ADM_TXT_301	constant varchar2(200)		:=  'Avg Row Len';
ADM_TXT_302	constant varchar2(200)		:=  'Sample Size';
ADM_TXT_303	constant varchar2(200)		:=  'Last Analysed';
ADM_TXT_304	constant varchar2(200)		:=  'Cost Statistics Indexes';
ADM_TXT_305	constant varchar2(200)		:=  'Index Name';
ADM_TXT_306	constant varchar2(200)		:=  'PCT Free';
ADM_TXT_307	constant varchar2(200)		:=  'Blevel';
ADM_TXT_308	constant varchar2(200)		:=  'Leaf Blocks';
ADM_TXT_309	constant varchar2(200)		:=  'Distinct Keys';
ADM_TXT_310	constant varchar2(200)		:=  'Avg Leaf Blocks';

ADM_TXT_311	constant varchar2(200)		:=  'Avg Data Blocks';
ADM_TXT_312	constant varchar2(200)		:=  'Organisation';
ADM_TXT_313	constant varchar2(200)		:=  'Person';
ADM_TXT_314	constant varchar2(200)		:=  'Estimate Statistics';
ADM_TXT_315	constant varchar2(200)		:=  'Lob Statistics';
ADM_TXT_316	constant varchar2(200)		:=  'Lob Name';
ADM_TXT_317	constant varchar2(200)		:=  'Column Name';
ADM_TXT_318	constant varchar2(200)		:=  'Chunk';
ADM_TXT_319	constant varchar2(200)		:=  'Lob Index Statistics';
ADM_TXT_320	constant varchar2(200)		:=  'Lob Index Name';

ADM_TXT_321	constant varchar2(200)		:=  'Database';
ADM_TXT_322	constant varchar2(200)		:=  'Large Load of Photos from an External Directory';
ADM_TXT_323	constant varchar2(200)		:=  'Score';
ADM_TXT_324	constant varchar2(200)		:=  'Directory where photos are located';
ADM_TXT_325	constant varchar2(200)		:=  'Directory and filename wildcard entry';
ADM_TXT_326	constant varchar2(200)		:=  'Directory where file listing is located';
ADM_TXT_327	constant varchar2(200)		:=  'Name of file containing photos';
ADM_TXT_328	constant varchar2(200)		:=  'Database Health Report';
ADM_TXT_329	constant varchar2(200)		:=  'Todays Date';
ADM_TXT_330	constant varchar2(200)		:=  'Do Not Compress if the Photo is smaller than (Kb)';

ADM_TXT_331	constant varchar2(200)		:=  'Person who did the Health Check';
ADM_TXT_332	constant varchar2(200)		:=  'Thumbnail Quality Compression';
ADM_TXT_333	constant varchar2(200)		:=  'Database Name';
ADM_TXT_334	constant varchar2(200)		:=  'Date Check Performed';
ADM_TXT_335	constant varchar2(200)		:=  'Prefix to be used for photo name';
ADM_TXT_336	constant varchar2(200)		:=  'Notes Before';
ADM_TXT_337	constant varchar2(200)		:=  'Try to reduce to size in (Kb)';
ADM_TXT_338	constant varchar2(200)		:=  'Only look at photos greater in size than (Kb)';
ADM_TXT_339	constant varchar2(200)		:=  'Load Images/Products';
ADM_TXT_340	constant varchar2(200)		:=  'Create a New Customer Account';

ADM_TXT_341	constant varchar2(200)		:=  'Customer account will not have any passwords set.';
ADM_TXT_342	constant varchar2(200)		:=  'Customer Account Name';
ADM_TXT_343	constant varchar2(200)		:=  'Client Customer Account Reference ID';
ADM_TXT_344	constant varchar2(200)		:=  'Create a New Account';
ADM_TXT_345	constant varchar2(200)		:=  'Error this account already exists';
ADM_TXT_346	constant varchar2(200)		:=  'Account Created';
ADM_TXT_349	constant varchar2(200)		:=  'Error Reading Directory';
ADM_TXT_350	constant varchar2(200)		:=  'Colour';

ADM_TXT_351	constant varchar2(200)		:=  'No Name';
ADM_TXT_352	constant varchar2(200)		:=  'File Ignored: File size was 0 bytes';
ADM_TXT_354	constant varchar2(200)		:=  'Error on Load';
ADM_TXT_356	constant varchar2(200)		:=  'Load Completed at time';
ADM_TXT_357	constant varchar2(200)		:=  'Total Time in seconds';
ADM_TXT_358	constant varchar2(200)		:=  'Avg Time to Load a Photo';
ADM_TXT_359	constant varchar2(200)		:=  'Number of Photographs Successfully Loaded';
ADM_TXT_360	constant varchar2(200)		:=  'Orders Received for all Clients';

ADM_TXT_361	constant varchar2(200)		:=  'Notes After';
ADM_TXT_362	constant varchar2(200)		:=  'Responses to all Questions';
ADM_TXT_365	constant varchar2(200)		:=  'Health Check not found';
ADM_TXT_366	constant varchar2(200)		:=  'Database SID';
ADM_TXT_367	constant varchar2(200)		:=  'Created';
ADM_TXT_368	constant varchar2(200)		:=  'Instance Number';
ADM_TXT_369	constant varchar2(200)		:=  'Host Name';
ADM_TXT_370	constant varchar2(200)		:=  'Version';

ADM_TXT_371	constant varchar2(200)		:=  'Startup Time';
ADM_TXT_372	constant varchar2(200)		:=  'Load using Manufacturer Format';
ADM_TXT_373	constant varchar2(200)		:=  'Load using supplied CD Format';
ADM_TXT_374	constant varchar2(200)		:=  'Load by specifying file listing';
ADM_TXT_375	constant varchar2(200)		:=  'Load by file wildcard';
ADM_TXT_376	constant varchar2(200)		:=  'No Customer Accounts Exist Yet';
ADM_TXT_377	constant varchar2(200)		:=  'Large Load of Photos based using Lab Standard';
ADM_TXT_378	constant varchar2(200)		:=  'Large Load of Photos based on Form Details entered by the Client';
ADM_TXT_379	constant varchar2(200)		:=  'Display to<BR>Customer';
ADM_TXT_380	constant varchar2(200)		:=  'Exception Report';

ADM_TXT_381	constant varchar2(200)		:=  'Total Score';
ADM_TXT_382	constant varchar2(200)		:=  'Grading - University';
ADM_TXT_383	constant varchar2(200)		:=  'Upload Details';
ADM_TXT_384	constant varchar2(200)		:=  'File Name Format';
ADM_TXT_385	constant varchar2(200)		:=  'Photos';
ADM_TXT_386	constant varchar2(200)		:=  'Folder';
ADM_TXT_387	constant varchar2(200)		:=  'Press to UpLoad CD';
ADM_TXT_388	constant varchar2(200)		:=  'Do Not Load';
ADM_TXT_389	constant varchar2(200)		:=  'No Data for';
ADM_TXT_390	constant varchar2(200)		:=  'Load CD';

ADM_TXT_391	constant varchar2(200)		:=  'Folder ID';
ADM_TXT_392	constant varchar2(200)		:=  'Business Feature Management';
ADM_TXT_394	constant varchar2(200)		:=  'Grading - School';
ADM_TXT_395	constant varchar2(200)		:=  'Business Feature Name';
ADM_TXT_396	constant varchar2(200)		:=  'Insert';
ADM_TXT_397	constant varchar2(200)		:=  'Site Complexity';
ADM_TXT_398	constant varchar2(200)		:=  'Download This Major Theme';
ADM_TXT_399	constant varchar2(200)		:=  'Cannot delete this Business Feature as Clients are mapped to it';
ADM_TXT_400	constant varchar2(200)		:=  'Has been deleted';

ADM_TXT_401	constant varchar2(200)		:=  'Cannot Insert as this Business Already Exists';
ADM_TXT_403	constant varchar2(200)		:=  'Type of User';
ADM_TXT_404	constant varchar2(200)		:=  'Is Beta Tester?';
ADM_TXT_405	constant varchar2(200)		:=  'Modify Beta Testers';
ADM_TXT_409	constant varchar2(200)		:=  'Size of all Programs';
ADM_TXT_410	constant varchar2(200)		:=  'Health Check';

ADM_TXT_411	constant varchar2(200)		:=  'Object Name';
ADM_TXT_412	constant varchar2(200)		:=  '# Lines of Code';
ADM_TXT_413	constant varchar2(200)		:=  'Reset';
ADM_TXT_414	constant varchar2(200)		:=  'Click on the Account Name to Modify the Expiry Date or Change the Charge Plan';
ADM_TXT_415	constant varchar2(200)		:=  'Date Expires';
ADM_TXT_416	constant varchar2(200)		:=  'Modify Customer Expiry';
ADM_TXT_417	constant varchar2(200)		:=  'Modify Expiry';
ADM_TXT_418	constant varchar2(200)		:=  'New Expiry Date';
ADM_TXT_419	constant varchar2(200)		:=  'Unload Plans';
ADM_TXT_420	constant varchar2(200)		:=  'Create New Unload Plan';

ADM_TXT_421	constant varchar2(200)		:=  'Data Unload Plan';
ADM_TXT_422	constant varchar2(200)		:=  'Unload Plan Name';
ADM_TXT_423	constant varchar2(200)		:=  'Drop';
ADM_TXT_424	constant varchar2(200)		:=  'Output File Name';
ADM_TXT_425	constant varchar2(200)		:=  'Include Column Names in Heading';
ADM_TXT_426	constant varchar2(200)		:=  'Where Clause (optional)';
ADM_TXT_427	constant varchar2(200)		:=  'Columns to unload';
ADM_TXT_428	constant varchar2(200)		:=  'Question';
ADM_TXT_429	constant varchar2(200)		:=  'Order By';
ADM_TXT_430	constant varchar2(200)		:=  'Insert/Update Details';

ADM_TXT_431	constant varchar2(200)		:=  'Delete Unload Plan';
ADM_TXT_432	constant varchar2(200)		:=  'Run this Plan';
ADM_TXT_433	constant varchar2(200)		:=  'Deleted';
ADM_TXT_434	constant varchar2(200)		:=  'Data has been Unloaded';
ADM_TXT_435	constant varchar2(200)		:=  'Data Modification Successful';
ADM_TXT_436	constant varchar2(200)		:=  'Unloaded into file';
ADM_TXT_437	constant varchar2(200)		:=  'Error in UTL_FILE: Value Error';
ADM_TXT_438	constant varchar2(200)		:=  'General Error in UTL_FILE';
ADM_TXT_439	constant varchar2(200)		:=  'Upload Business/Look and Feel/Category';
ADM_TXT_440	constant varchar2(200)		:=  'File Name (located in the p:\piction\report_load) directory';

ADM_TXT_441	constant varchar2(200)		:=  'Replace Record if it exists';
ADM_TXT_442	constant varchar2(200)		:=  'Confirm before replacing record';
ADM_TXT_443	constant varchar2(200)		:=  'Upload';
ADM_TXT_444	constant varchar2(200)		:=  'This record already exists.';
ADM_TXT_445	constant varchar2(200)		:=  'Press to Replace Record with the new uploaded one' ;
ADM_TXT_446	constant varchar2(200)		:=  'Record Definition Loaded';
ADM_TXT_447	constant varchar2(200)		:=  'Report on Business Features, Look and Feels and Categories';
ADM_TXT_450	constant varchar2(200)		:=  'Look and Feels';

ADM_TXT_451	constant varchar2(200)		:=  'Business features mapped to';
ADM_TXT_453	constant varchar2(200)		:=  'Invalid Date Entered. Must be of format DD-MON-YYYY.';
ADM_TXT_454	constant varchar2(200)		:=  'Account Successfully Modified';
ADM_TXT_455	constant varchar2(200)		:=  'Invalid Money Value Entered. Must be of format $999,999.99';
ADM_TXT_456	constant varchar2(200)		:=  'Client Charge Plan Management';
ADM_TXT_457	constant varchar2(200)		:=  'Account Enabled';
ADM_TXT_458	constant varchar2(200)		:=  'Date Expires (DD-MON-YYYY)';
ADM_TXT_459	constant varchar2(200)		:=  'Date Renewal is to be sent (DD-MON-YYYY)';
ADM_TXT_460	constant varchar2(200)		:=  'Client has acknowledged Renewal is due';

ADM_TXT_461	constant varchar2(200)		:=  'Modify Expiry Date';
ADM_TXT_462	constant varchar2(200)		:=  'Payment History';
ADM_TXT_463	constant varchar2(200)		:=  'Date Paid';
ADM_TXT_464	constant varchar2(200)		:=  'Amount Paid';
ADM_TXT_465	constant varchar2(200)		:=  'No Payments have been made by this Client';
ADM_TXT_466	constant varchar2(200)		:=  'Renewal Dates Sent History';
ADM_TXT_467	constant varchar2(200)		:=  'Date Renewal Sent';
ADM_TXT_468	constant varchar2(200)		:=  'No Renewals have ever been sent to this Client';
ADM_TXT_469	constant varchar2(200)		:=  'Add new Date Paid Entry';
ADM_TXT_470	constant varchar2(200)		:=  'Date Paid (DD-MON-YYYY)';

ADM_TXT_471	constant varchar2(200)		:=  'Amount Paid ($999,999.99)';
ADM_TXT_472	constant varchar2(200)		:=  'Insert Entry';
ADM_TXT_473	constant varchar2(200)		:=  'Extra Notes';
ADM_TXT_474	constant varchar2(200)		:=  'Send a Renewal Reminder to the Client Now';
ADM_TXT_475	constant varchar2(200)		:=  'Reminder Notice';
ADM_TXT_476	constant varchar2(200)		:=  'Renewal Sent';
ADM_TXT_477	constant varchar2(200)		:=  'Piction Storage Manager';
ADM_TXT_478	constant varchar2(200)		:=  'Storage Area';
ADM_TXT_479	constant varchar2(200)		:=  'Total (Mb)';
ADM_TXT_480	constant varchar2(200)		:=  'Free (Mb)';

ADM_TXT_481	constant varchar2(200)		:=  'Remaining %';
ADM_TXT_482	constant varchar2(200)		:=  'Option';
ADM_TXT_483	constant varchar2(200)		:=  'Total Database';
ADM_TXT_484	constant varchar2(200)		:=  'Piction Images';
ADM_TXT_485	constant varchar2(200)		:=  'Add More Storage';
ADM_TXT_486	constant varchar2(200)		:=  'Storage';
ADM_TXT_487	constant varchar2(200)		:=  'Piction Data';
ADM_TXT_488	constant varchar2(200)		:=  'Other Data';
ADM_TXT_489	constant varchar2(200)		:=  'Piction Image Statistics';
ADM_TXT_490	constant varchar2(200)		:=  '# Images';

ADM_TXT_491	constant varchar2(200)		:=  'Original Allocated (Kb)';
ADM_TXT_492	constant varchar2(200)		:=  'Web Allocated (Kb)';
ADM_TXT_493	constant varchar2(200)		:=  'Backup Allocated (Kb)';
ADM_TXT_494	constant varchar2(200)		:=  'Thumbnail Allocated (Kb)';
ADM_TXT_495	constant varchar2(200)		:=  'Total Image Allocated (Kb)';
ADM_TXT_496	constant varchar2(200)		:=  'Total Used within Allocation (Kb)';
ADM_TXT_497	constant varchar2(200)		:=  'Avg Photo Size (Kb)';
ADM_TXT_498	constant varchar2(200)		:=  'Guess at number photos that could be stored';
ADM_TXT_499	constant varchar2(200)		:=  'Unable to calculate storage clause';
ADM_TXT_500	constant varchar2(200)		:=  'Storage File Name';

ADM_TXT_501	constant varchar2(200)		:=  'Allocated (Mb)';
ADM_TXT_502	constant varchar2(200)		:=  'Free';
ADM_TXT_503	constant varchar2(200)		:=  'Size in Mb';
ADM_TXT_504	constant varchar2(200)		:=  'Before adding this storage check the following';
ADM_TXT_505	constant varchar2(200)		:=  '1. The disk drive to to create the file to add the storage is correct';
ADM_TXT_506	constant varchar2(200)		:=  '2. The directory structure exists to create the file';
ADM_TXT_507	constant varchar2(200)		:=  '3. There is sufficient storage for this file to be created on the disk';
ADM_TXT_508	constant varchar2(200)		:=  'Use this screen to redirect a Client and all customer accounts to another node when they login.';
ADM_TXT_509	constant varchar2(200)		:=  'Redirect to site';
ADM_TXT_510	constant varchar2(200)		:=  'Redirect to Site';

ADM_TXT_511	constant varchar2(200)		:=  'Complexity';
ADM_TXT_512	constant varchar2(200)		:=  'Redirect Site';
ADM_TXT_513	constant varchar2(200)		:=  'Customer Profile';
ADM_TXT_514	constant varchar2(200)		:=  'Client and Customers Updated';
ADM_TXT_515	constant varchar2(200)		:=  'Clients referencing that site';
ADM_TXT_516	constant varchar2(200)		:=  'Modify Redirect Sites';
ADM_TXT_517	constant varchar2(200)		:=  'Cannot delete as Clients are referencing this site.';
ADM_TXT_518	constant varchar2(200)		:=  'Details Updated';
ADM_TXT_519	constant varchar2(200)		:=  'Add Storage';
ADM_TXT_520	constant varchar2(200)		:=  'Running the command';

ADM_TXT_521	constant varchar2(200)		:=  'Failed';
ADM_TXT_522	constant varchar2(200)		:=  'Extract a Slideshow to a Directory';
ADM_TXT_523	constant varchar2(200)		:=  'Extract';
ADM_TXT_524	constant varchar2(200)		:=  'Directory where HTML and JPGs are to be stored e.g. e:\sld\ ';
ADM_TXT_525	constant varchar2(200)		:=  'Slide Show Name';
ADM_TXT_526	constant varchar2(200)		:=  '# Slides';
ADM_TXT_527	constant varchar2(200)		:=  'You must choose at least one slideshow';
ADM_TXT_528	constant varchar2(200)		:=  'Dumping Information for slideshow';
ADM_TXT_529	constant varchar2(200)		:=  'Dumped Photo';
ADM_TXT_530	constant varchar2(200)		:=  'Dumping Auto HTML for Slide';

ADM_TXT_531	constant varchar2(200)		:=  'Dumping Manual HTML for Slide';
ADM_TXT_532	constant varchar2(200)		:=  '[Manual]';
ADM_TXT_533	constant varchar2(200)		:=  '[Automatic]';
ADM_TXT_534	constant varchar2(200)		:=  '[Home Page]';
ADM_TXT_535	constant varchar2(200)		:=  'Dumping index.htm';
ADM_TXT_536	constant varchar2(200)		:=  'Slideshow Presentation';
ADM_TXT_537	constant varchar2(200)		:=  'Finished Dump';
ADM_TXT_538	constant varchar2(200)		:=  'Run Slideshow by opening the file';
ADM_TXT_539	constant varchar2(200)		:=  'Database Health Check';
ADM_TXT_540	constant varchar2(200)		:=  'Edit by';

ADM_TXT_542	constant varchar2(200)		:=  'The administration password you entered is not correct.';
ADM_TXT_543	constant varchar2(200)		:=  'The new password entered and the confirmation password do not match.';
ADM_TXT_544	constant varchar2(200)		:=  'Account Details Modified.';
ADM_TXT_545	constant varchar2(200)		:=  'Customer Type.';
ADM_TXT_546	constant varchar2(200)		:=  'Guest';
ADM_TXT_547	constant varchar2(200)		:=  'Use File Name';
ADM_TXT_548	constant varchar2(200)		:=  'Large Photo Load Details';
ADM_TXT_549	constant varchar2(200)		:=  'Unable to access the directory';
ADM_TXT_550	constant varchar2(200)		:=  'Unable to Write File';

ADM_TXT_551	constant varchar2(200)		:=  'Manage Meta Tags';
ADM_TXT_552	constant varchar2(200)		:=  'Tag Type';
ADM_TXT_553	constant varchar2(200)		:=  'Report';
ADM_TXT_554	constant varchar2(200)		:=  'Sub Category';
ADM_TXT_555	constant varchar2(200)		:=  'Mandatory';
ADM_TXT_556	constant varchar2(200)		:=  'Edited';
ADM_TXT_557	constant varchar2(200)		:=  'Max Length';
ADM_TXT_558	constant varchar2(200)		:=  'Add Meta Tags';
ADM_TXT_559	constant varchar2(200)		:=  'Meta Tags Successfully Added';

ADM_TXT_561	constant varchar2(200)		:=  'Response';
ADM_TXT_562	constant varchar2(200)		:=  'Save';
ADM_TXT_563	constant varchar2(200)		:=  'Click on the Question to answer it.';
ADM_TXT_564	constant varchar2(200)		:=  'Click on the Group to display all the questions for it.';
ADM_TXT_565	constant varchar2(200)		:=  'Edit Questions';
ADM_TXT_566	constant varchar2(200)		:=  'Instructions';
ADM_TXT_567	constant varchar2(200)		:=  'Grade not found';
ADM_TXT_568	constant varchar2(200)		:=  'Unknown Parameter Code';
ADM_TXT_569	constant varchar2(200)		:=  'Fuzzy Boolean Response Not Found';
ADM_TXT_570	constant varchar2(200)		:=  'LOV Not Found';

ADM_TXT_571	constant varchar2(200)		:=  'DRILL DOWN';
ADM_TXT_572	constant varchar2(200)		:=  'EXPAND ALL';
ADM_TXT_573	constant varchar2(200)		:=  'Display Category Bullet';
ADM_TXT_574	constant varchar2(200)		:=  'Nested Category Style';
ADM_TXT_575	constant varchar2(200)		:=  'MENU';
ADM_TXT_576	constant varchar2(200)		:=  'LOV';
ADM_TXT_577	constant varchar2(200)		:=  'New Title';
ADM_TXT_578	constant varchar2(200)		:=  'Nest Title';
ADM_TXT_579	constant varchar2(200)		:=  'Frame Position for Categories';
ADM_TXT_580	constant varchar2(200)		:=  'Top';

ADM_TXT_582	constant varchar2(200)		:=  'Parent Category';
ADM_TXT_583	constant varchar2(200)		:=  'LINK';
ADM_TXT_586	constant varchar2(200)		:=  'Client: Position Buttons above Categories';
ADM_TXT_587	constant varchar2(200)		:=  'Customer: Position Buttons above Categories';
ADM_TXT_588	constant varchar2(200)		:=  'Buttons';
ADM_TXT_590	constant varchar2(200)		:=  'Management/Control';

ADM_TXT_591	constant varchar2(200)		:=  'You must specify at least one file name';
ADM_TXT_592	constant varchar2(200)		:=  'Format Type';
ADM_TXT_593	constant varchar2(200)		:=  'These Virtual Directories can be appended to an FTP file name';
ADM_TXT_594	constant varchar2(200)		:=  'Description,HTTP Location';
ADM_TXT_595	constant varchar2(200)		:=  'Virtual Directory';
ADM_TXT_596	constant varchar2(200)		:=  'Modify Virtual Directories';
ADM_TXT_597	constant varchar2(200)		:=  'Download Type';
ADM_TXT_598	constant varchar2(200)		:=  'Length';
ADM_TXT_599	constant varchar2(200)		:=  'Format';
ADM_TXT_600	constant varchar2(200)		:=  'FTP';

ADM_TXT_601	constant varchar2(200)		:=  'Nested Category Delimiter Character';
ADM_TXT_602	constant varchar2(200)		:=  'This Image can be Downloaded';
ADM_TXT_603	constant varchar2(200)		:=  'The Original for this Image is not available for Download';
ADM_TXT_604	constant varchar2(200)		:=  'Update Health Check Header';
ADM_TXT_605	constant varchar2(200)		:=  'Person Performing Check';
ADM_TXT_606	constant varchar2(200)		:=  'Language';
ADM_TXT_607	constant varchar2(200)		:=  'Database Vendor';
ADM_TXT_608	constant varchar2(200)		:=  'Update';
ADM_TXT_609	constant varchar2(200)		:=  'Edit a Group of Questions';
ADM_TXT_610	constant varchar2(200)		:=  'Updated';

ADM_TXT_611	constant varchar2(200)		:=  'Boolean';
ADM_TXT_612	constant varchar2(200)		:=  'EMAIL';
ADM_TXT_613	constant varchar2(200)		:=  'To find answer';
ADM_TXT_614	constant varchar2(200)		:=  'On Save control is returned to the LEFT Frame';
ADM_TXT_615	constant varchar2(200)		:=  'Error on Update';
ADM_TXT_616	constant varchar2(200)		:=  'Press the BACK Button and correct problem';
ADM_TXT_617	constant varchar2(200)		:=  'Health Report';
ADM_TXT_618	constant varchar2(200)		:=  'Choose Report Options';
ADM_TXT_619	constant varchar2(200)		:=  'Summary';
ADM_TXT_620	constant varchar2(200)		:=  'All Questions';

ADM_TXT_621	constant varchar2(200)		:=  'Exceptions';
ADM_TXT_622	constant varchar2(200)		:=  'Score By Group';
ADM_TXT_623	constant varchar2(200)		:=  'Grade';
ADM_TXT_624	constant varchar2(200)		:=  'Run Report';
ADM_TXT_625	constant varchar2(200)		:=  'Health Report Comparison';
ADM_TXT_626	constant varchar2(200)		:=  'Compare Two Health Checks';
ADM_TXT_627	constant varchar2(200)		:=  'Check';
ADM_TXT_628	constant varchar2(200)		:=  'Compare';
ADM_TXT_629	constant varchar2(200)		:=  'New Health Check';
ADM_TXT_630	constant varchar2(200)		:=  'Note Before';

ADM_TXT_631	constant varchar2(200)		:=  'Press BACK Button and re-enter valid date.';
ADM_TXT_632	constant varchar2(200)		:=  'must be of format';
ADM_TXT_633	constant varchar2(200)		:=  'Invalid Date';
ADM_TXT_634	constant varchar2(200)		:=  'Differences';
ADM_TXT_635	constant varchar2(200)		:=  'Role';
ADM_TXT_636	constant varchar2(200)		:=  'Administrator Accounts';
ADM_TXT_637	constant varchar2(200)		:=  'Administrator Roles';
ADM_TXT_638	constant varchar2(200)		:=  'Top Menu';
ADM_TXT_639	constant varchar2(200)		:=  'Menu Item';
ADM_TXT_640	constant varchar2(200)		:=  'Create New Role';

ADM_TXT_641	constant varchar2(200)		:=  'Manage Role Details';
ADM_TXT_642	constant varchar2(200)		:=  'Role Modified';
ADM_TXT_643	constant varchar2(200)		:=  'Name,Email Address';
ADM_TXT_647	constant varchar2(200)		:=  'Role Name is empty.';
ADM_TXT_648	constant varchar2(200)		:=  'Create New Administrator Account';
ADM_TXT_649	constant varchar2(200)		:=  'Delete Administrator Account';
ADM_TXT_650	constant varchar2(200)		:=  'You must enter in the name of the new User';

ADM_TXT_651	constant varchar2(200)		:=  'This username conflicts with';
ADM_TXT_652	constant varchar2(200)		:=  'Manage Account';
ADM_TXT_653	constant varchar2(200)		:=  'Administrator Account Deleted';
ADM_TXT_654	constant varchar2(200)		:=  'Delete Administrator Role';
ADM_TXT_655	constant varchar2(200)		:=  'Administrator Role Deleted';
ADM_TXT_656	constant varchar2(200)		:=  'You have logged into';
ADM_TXT_659	constant varchar2(200)		:=  'Login Type';
ADM_TXT_660	constant varchar2(200)		:=  'Time last connected';

ADM_TXT_661	constant varchar2(200)		:=  'Disconnect Session';
ADM_TXT_662	constant varchar2(200)		:=  'Session Disconnected';
ADM_TXT_664	constant varchar2(200)		:=  'Hourly Login Number over the last 3 Months';
ADM_TXT_665	constant varchar2(200)		:=  'Hour Period';
ADM_TXT_666	constant varchar2(200)		:=  'Number Logins';
ADM_TXT_667	constant varchar2(200)		:=  'Months';
ADM_TXT_668	constant varchar2(200)		:=  'Days';
ADM_TXT_669	constant varchar2(200)		:=  'Hours';
ADM_TXT_670	constant varchar2(200)		:=  'Clients';

ADM_TXT_671	constant varchar2(200)		:=  'Owners';
ADM_TXT_672	constant varchar2(200)		:=  'Guests';
ADM_TXT_673	constant varchar2(200)		:=  'Drill Down on Login Session';
ADM_TXT_674	constant varchar2(200)		:=  'Cull Audit Records';
ADM_TXT_675	constant varchar2(200)		:=  'Cull Login Session';
ADM_TXT_676	constant varchar2(200)		:=  'Cull Audit All Activity';
ADM_TXT_677	constant varchar2(200)		:=  'Cull C Program Usage';
ADM_TXT_678	constant varchar2(200)		:=  'Records';
ADM_TXT_679	constant varchar2(200)		:=  'Records successfully culled';
ADM_TXT_680	constant varchar2(200)		:=  'Delete Records older than days';

ADM_TXT_682	constant varchar2(200)		:=  'Add New Business Feature';
ADM_TXT_684	constant varchar2(200)		:=  'Edit All Features';
ADM_TXT_685	constant varchar2(200)		:=  'Business Feature Modified';
ADM_TXT_686	constant varchar2(200)		:=  'Enable all these Business Feature Categories';
ADM_TXT_687	constant varchar2(200)		:=  'Cross Reference Report';
ADM_TXT_690	constant varchar2(200)		:=  'Enable Images';

ADM_TXT_691	constant varchar2(200)		:=  'Low';
ADM_TXT_692	constant varchar2(200)		:=  'Med';
ADM_TXT_693	constant varchar2(200)		:=  'High';
ADM_TXT_695	constant varchar2(200)		:=  'All IP Address are Restricted except for';
ADM_TXT_696	constant varchar2(200)		:=  'All IP Address are Allowed except for';
ADM_TXT_697	constant varchar2(200)		:=  'IP Address list';
ADM_TXT_698	constant varchar2(200)		:=  'Wildcards allowed (eg. 140.83.*.*)';
ADM_TXT_699	constant varchar2(200)		:=  'Update IP Address list';
ADM_TXT_700	constant varchar2(200)		:=  'IP Address list Updated';

ADM_TXT_701	constant varchar2(200)		:=  'Access has been Restricted.';
ADM_TXT_702	constant varchar2(200)		:=  'Password Expiry Date (Empty is no expiry)';
ADM_TXT_703	constant varchar2(200)		:=  'Days until Password Expires (Empty is no expiry)';
ADM_TXT_704	constant varchar2(200)		:=  'Password Attempts (Empty is no check)';
ADM_TXT_707	constant varchar2(200)		:=  'Current Password Attempts';
ADM_TXT_708	constant varchar2(200)		:=  'Unlimited';
ADM_TXT_709	constant varchar2(200)		:=  'Expired';
ADM_TXT_710	constant varchar2(200)		:=  'Reset Failed Logins';

ADM_TXT_711	constant varchar2(200)		:=  'Number of Failed Logins';
ADM_TXT_712	constant varchar2(200)		:=  'Choose Category Name';
ADM_TXT_713	constant varchar2(200)		:=  'Error Opening File';
ADM_TXT_714	constant varchar2(200)		:=  'Accessing the following file to retrieve file names';
ADM_TXT_715	constant varchar2(200)		:=  'Same Directory as file location';
ADM_TXT_716	constant varchar2(200)		:=  'Queried';
ADM_TXT_717	constant varchar2(200)		:=  'Meta Type';
ADM_TXT_718	constant varchar2(200)		:=  'VARCHAR';
ADM_TXT_719	constant varchar2(200)		:=  'NUMBER';
ADM_TXT_720	constant varchar2(200)		:=  'INTEGER';

ADM_TXT_721	constant varchar2(200)		:=  'DATE';
ADM_TXT_722	constant varchar2(200)		:=  'TIME';
ADM_TXT_723	constant varchar2(200)		:=  'User Defined Meta Tags';
ADM_TXT_724	constant varchar2(200)		:=  'System Meta Tags';
ADM_TXT_725	constant varchar2(200)		:=  'Convert from Private to Public';
ADM_TXT_726	constant varchar2(200)		:=  'Client Category Converted to a Public Category';
ADM_TXT_728	constant varchar2(200)		:=  'Bypass Quota Check';
ADM_TXT_729	constant varchar2(200)		:=  'Invalid Tag Found';
ADM_TXT_730	constant varchar2(200)		:=  'Buffer';

ADM_TXT_731	constant varchar2(200)		:=  'Category Deduced';
ADM_TXT_732	constant varchar2(200)		:=  'Listing of all Parameters passed to Load Call';
ADM_TXT_733	constant varchar2(200)		:=  'List of Values<BR><I>(comma separated)</I>';
ADM_TXT_734	constant varchar2(200)		:=  'Meta Tag Exception Report';
ADM_TXT_735	constant varchar2(200)		:=  'Meta Tag Error';
ADM_TXT_736	constant varchar2(200)		:=  'No Bad Meta Tags Found';
ADM_TXT_737	constant varchar2(200)		:=  'Load Meta Tags even if Bad';
ADM_TXT_738	constant varchar2(200)		:=  'Bad Meta Tag Found. Not Loaded.';
ADM_TXT_739	constant varchar2(200)		:=  'Bad Meta Tag Found. Still Loaded.';
ADM_TXT_740	constant varchar2(200)		:=  'Could not find closing bracket for this tag';

ADM_TXT_741	constant varchar2(200)		:=  'Could not find matching end tag for XML tag ';
ADM_TXT_742	constant varchar2(200)		:=  'Meta Tag is not defined';
ADM_TXT_743	constant varchar2(200)		:=  'XML Tag';
ADM_TXT_744	constant varchar2(200)		:=  'XML Tag Value';
ADM_TXT_747	constant varchar2(200)		:=  'Add New Business Feature using Template';
ADM_TXT_748	constant varchar2(200)		:=  'Cannot Locate the file';
ADM_TXT_750	constant varchar2(200)		:=  'Load Time';

ADM_TXT_751	constant varchar2(200)		:=  'Filename';
ADM_TXT_752	constant varchar2(200)		:=  'Suceeded (T/F)<BR>or Ignored (I)<BR>or Bad Meta Tag (M)<BR>or Bad File.Txt (B)';
ADM_TXT_753	constant varchar2(200)		:=  'Error Returned';
ADM_TXT_754	constant varchar2(200)		:=  'Delete Log File';
ADM_TXT_755	constant varchar2(200)		:=  'Log has been Deleted';
ADM_TXT_756	constant varchar2(200)		:=  'Display Log File from Last Load';
ADM_TXT_757	constant varchar2(200)		:=  'No Log File Entries Found';
ADM_TXT_758	constant varchar2(200)		:=  'Tag Value/Aid/Global Category Id';
ADM_TXT_759	constant varchar2(200)		:=  'Number of Photographs NOT Successfully Loaded';
ADM_TXT_760	constant varchar2(200)		:=  'Ignore Load if file already exists';

ADM_TXT_761	constant varchar2(200)		:=  'Ignored';
ADM_TXT_762	constant varchar2(200)		:=  'File Location';
ADM_TXT_763	constant varchar2(200)		:=  'Attributes';
ADM_TXT_764	constant varchar2(200)		:=  'Generate';
ADM_TXT_765	constant varchar2(200)		:=  'Create Sub-Directory as Category Name if it does not exist';
ADM_TXT_766	constant varchar2(200)		:=  'Create Sub-Directory PUBLIC';
ADM_TXT_767	constant varchar2(200)		:=  'Run in Batch. Hour/Minute<BR>Day Month Year';

ADM_TXT_773	constant varchar2(200)		:=  'Other Orders';
ADM_TXT_774	constant varchar2(200)		:=  'Orders by Month';
ADM_TXT_775	constant varchar2(200)		:=  'FTP Upload Location';
ADM_TXT_776	constant varchar2(200)		:=  'Delete from Queue';
ADM_TXT_778	constant varchar2(200)		:=  'New Orders made from Midnight Yesterday';
ADM_TXT_779	constant varchar2(200)		:=  'Administrator Load';
ADM_TXT_780	constant varchar2(200)		:=  'Display Purchase Request';

ADM_TXT_781	constant varchar2(200)		:=  'Send to Details';
ADM_TXT_782	constant varchar2(200)		:=  'Total Payment';
ADM_TXT_783	constant varchar2(200)		:=  'Program Called';
ADM_TXT_784	constant varchar2(200)		:=  'Image Viewed';
ADM_TXT_785	constant varchar2(200)		:=  'Time Accessed';
ADM_TXT_786	constant varchar2(200)		:=  'Charge Event Plans';
ADM_TXT_787	constant varchar2(200)		:=  'Plan Event Name';
ADM_TXT_788	constant varchar2(200)		:=  'Maximum Number of Images';
ADM_TXT_789	constant varchar2(200)		:=  'Modify Client Event Charge Plan';

ADM_TXT_791	constant varchar2(200)		:=  'Current Utilisation';
ADM_TXT_792	constant varchar2(200)		:=  'Option 1: Royalty Discount %';
ADM_TXT_793	constant varchar2(200)		:=  'Option 1: Royalty Exacted %';
ADM_TXT_794	constant varchar2(200)		:=  'Option 2: Bulk Discount %';
ADM_TXT_795	constant varchar2(200)		:=  'Quick add of New Meta Tags';
ADM_TXT_796	constant varchar2(200)		:=  'Handling';
ADM_TXT_797	constant varchar2(200)		:=  'Client Receives';
ADM_TXT_800	constant varchar2(200)		:=  'Left Hand Frame cannot be removed with these settings.';

ADM_TXT_802	constant varchar2(200)		:=  'Remove Credit Card Details';
ADM_TXT_803	constant varchar2(200)		:=  'No Frames';
ADM_TXT_804	constant varchar2(200)		:=  'Top and Bottom Frame Only';
ADM_TXT_805	constant varchar2(200)		:=  'Top, Bottom and Left Hand Frame';
ADM_TXT_806	constant varchar2(200)		:=  'Top, Bottom and Right Hand Frame';
ADM_TXT_807	constant varchar2(200)		:=  'Row 1';
ADM_TXT_808	constant varchar2(200)		:=  'Row 2';
ADM_TXT_809	constant varchar2(200)		:=  'Row 3';
ADM_TXT_810	constant varchar2(200)		:=  'Scrollbar';

ADM_TXT_811	constant varchar2(200)		:=  'All Icons';
ADM_TXT_812	constant varchar2(200)		:=  'Adverts';
ADM_TXT_813	constant varchar2(200)		:=  'Client Title';
ADM_TXT_814	constant varchar2(200)		:=  'Location of Objects in the Top Frame';
ADM_TXT_815	constant varchar2(200)		:=  'Use of Frames';
ADM_TXT_816	constant varchar2(200)		:=  'MONEY';
ADM_TXT_817	constant varchar2(200)		:=  'Trading Interest Groups';
ADM_TXT_820	constant varchar2(200)		:=  'Customers linked to the Interest Group';

ADM_TXT_821	constant varchar2(200)		:=  'Colour Palette';
ADM_TXT_822	constant varchar2(200)		:=  'Jobs Scheduled to Run';
ADM_TXT_824	constant varchar2(200)		:=  'Dynamic Monitor';
ADM_TXT_825	constant varchar2(200)		:=  'V$SQLAREA: Top Executions';
ADM_TXT_826	constant varchar2(200)		:=  'V$SQLAREA: Top Disk Reads';
ADM_TXT_827	constant varchar2(200)		:=  'V$SQLAREA: Top Buffer Gets';
ADM_TXT_828	constant varchar2(200)		:=  'V$SQLAREA: Top Rows Processed';
ADM_TXT_829	constant varchar2(200)		:=  'V$SESSION / V$PROCESS';
ADM_TXT_830	constant varchar2(200)		:=  'V$SESSION_LONGOPS';

ADM_TXT_831	constant varchar2(200)		:=  'V$WAITSTAT';
ADM_TXT_832	constant varchar2(200)		:=  'SQL Statement';
ADM_TXT_833	constant varchar2(200)		:=  'Executions';
ADM_TXT_834	constant varchar2(200)		:=  'Disk Reads';
ADM_TXT_835	constant varchar2(200)		:=  'Buffer Gets';
ADM_TXT_836	constant varchar2(200)		:=  'Rows Processed';
ADM_TXT_837	constant varchar2(200)		:=  'Optimizer Mode';
ADM_TXT_838	constant varchar2(200)		:=  'Statement Statistics';
ADM_TXT_839	constant varchar2(200)		:=  'Same Statement but retrieve rows';
ADM_TXT_840	constant varchar2(200)		:=  'Run Query';

ADM_TXT_841	constant varchar2(200)		:=  'Query Statistics';
ADM_TXT_842	constant varchar2(200)		:=  'No Priveleges to run Explain Plan on underlying tables';
ADM_TXT_843	constant varchar2(200)		:=  'SID';
ADM_TXT_844	constant varchar2(200)		:=  'Serial#';
ADM_TXT_845	constant varchar2(200)		:=  'Program';
ADM_TXT_846	constant varchar2(200)		:=  'Time Logged On';
ADM_TXT_847	constant varchar2(200)		:=  'Start Time';
ADM_TXT_848	constant varchar2(200)		:=  'Elapsed Seconds';
ADM_TXT_849	constant varchar2(200)		:=  'Message';
ADM_TXT_850	constant varchar2(200)		:=  'Session Killed';

ADM_TXT_852	constant varchar2(200)		:=  'Count';
ADM_TXT_853	constant varchar2(200)		:=  'Ignore Data Dictionary Statements';
ADM_TXT_854	constant varchar2(200)		:=  'Report Definitions';
ADM_TXT_855	constant varchar2(200)		:=  'Add New Report';
ADM_TXT_856	constant varchar2(200)		:=  'Report Name';
ADM_TXT_857	constant varchar2(200)		:=  'Report Type';
ADM_TXT_858	constant varchar2(200)		:=  'Report Location';
ADM_TXT_859	constant varchar2(200)		:=  'Report Category';
ADM_TXT_860	constant varchar2(200)		:=  'Report Successfully Modified';

ADM_TXT_861	constant varchar2(200)		:=  'HTML';
ADM_TXT_862	constant varchar2(200)		:=  'SQL QUERY';
ADM_TXT_863	constant varchar2(200)		:=  'FORM';
ADM_TXT_864	constant varchar2(200)		:=  'PROCEDURE';
ADM_TXT_865	constant varchar2(200)		:=  'Modify Report Definition';
ADM_TXT_867	constant varchar2(200)		:=  'Report Parameters';
ADM_TXT_868	constant varchar2(200)		:=  'Parameter Name';
ADM_TXT_869	constant varchar2(200)		:=  'Parameter Type';
ADM_TXT_870	constant varchar2(200)		:=  'Parameter Value';

ADM_TXT_871	constant varchar2(200)		:=  'CONSTANT';
ADM_TXT_872	constant varchar2(200)		:=  'SQL';
ADM_TXT_873	constant varchar2(200)		:=  'Horizontal Customer<BR>Display';
ADM_TXT_874	constant varchar2(200)		:=  'Display to<BR>Client';
ADM_TXT_875	constant varchar2(200)		:=  'Manage Product Brands';
ADM_TXT_876	constant varchar2(200)		:=  'Brand Name';
ADM_TXT_877	constant varchar2(200)		:=  'Modify Interest Groups';
ADM_TXT_878	constant varchar2(200)		:=  'Modify Brands';
ADM_TXT_879	constant varchar2(200)		:=  'Manage Dictionary';
ADM_TXT_880	constant varchar2(200)		:=  'Dictionary';

ADM_TXT_881	constant varchar2(200)		:=  'Association';
ADM_TXT_882	constant varchar2(200)		:=  'Add New Term';
ADM_TXT_883	constant varchar2(200)		:=  'Search For';
ADM_TXT_884	constant varchar2(200)		:=  'Number to Display';
ADM_TXT_885	constant varchar2(200)		:=  'Results of Search';
ADM_TXT_886	constant varchar2(200)		:=  'No Terms Found';
ADM_TXT_887	constant varchar2(200)		:=  'Term Successfully Added';
ADM_TXT_888	constant varchar2(200)		:=  'Term Successfully Deleted';
ADM_TXT_889	constant varchar2(200)		:=  'Association cannot be empty';
ADM_TXT_890	constant varchar2(200)		:=  'Term Already Exists, cannot Insert';

ADM_TXT_891	constant varchar2(200)		:=  'Delete this Meta Tag';
ADM_TXT_892	constant varchar2(200)		:=  'Meta Tag has been Deleted';
ADM_TXT_893	constant varchar2(200)		:=  'Delete Colour';
ADM_TXT_894	constant varchar2(200)		:=  'Add New Colour';
ADM_TXT_895	constant varchar2(200)		:=  'Hex Value';
ADM_TXT_896	constant varchar2(200)		:=  'Edit Customer Display Objects';
ADM_TXT_897	constant varchar2(200)		:=  'Modify Objects';
ADM_TXT_898	constant varchar2(200)		:=  'Display Name';
ADM_TXT_899	constant varchar2(200)		:=  'Manage Fonts';
ADM_TXT_900	constant varchar2(200)		:=  'Font Name';

ADM_TXT_901	constant varchar2(200)		:=  'Fonts Modified';
ADM_TXT_902	constant varchar2(200)		:=  'Error talking to C Wildcard Program to get Directory Details';
ADM_TXT_903	constant varchar2(200)		:=  'Reload/Refresh Screen';
ADM_TXT_904	constant varchar2(200)		:=  'For Example';
ADM_TXT_905	constant varchar2(200)		:=  'Row 4';
ADM_TXT_906	constant varchar2(200)		:=  'Button Background Image (eg. lf_back.gif)';
ADM_TXT_907	constant varchar2(200)		:=  'Button Table Cell Pixel Width';
ADM_TXT_908	constant varchar2(200)		:=  'Button Table Cell Pixel Height';
ADM_TXT_909	constant varchar2(200)		:=  'Button Table Cell Image Vertical Align (Center, Top, Bottom)';
ADM_TXT_910	constant varchar2(200)		:=  'All Display Table Width (eg. width=100%)';

ADM_TXT_911	constant varchar2(200)		:=  'Manage Connections';
ADM_TXT_912	constant varchar2(200)		:=  'Also run the following reports if required';
ADM_TXT_913	constant varchar2(200)		:=  'Security Roles';
ADM_TXT_914	constant varchar2(200)		:=  'Create New Security Role';
ADM_TXT_915	constant varchar2(200)		:=  'Edit Security Role';
ADM_TXT_916	constant varchar2(200)		:=  'Role Name';
ADM_TXT_917	constant varchar2(200)		:=  'Type of Role';
ADM_TXT_918	constant varchar2(200)		:=  'Table Restrictive Role Options';
ADM_TXT_919	constant varchar2(200)		:=  'Where Clause Restrict or<BR>Value Restrict';

ADM_TXT_921	constant varchar2(200)		:=  'Where Clause or<BR>Column Name';
ADM_TXT_922	constant varchar2(200)		:=  'Expression';
ADM_TXT_924	constant varchar2(200)		:=  'Value Type';
ADM_TXT_926	constant varchar2(200)		:=  'Role Successfully Created';
ADM_TXT_928	constant varchar2(200)		:=  'Role Deleted';
ADM_TXT_929	constant varchar2(200)		:=  'Role with this Name Already Exists. Cannot Create.';
ADM_TXT_930	constant varchar2(200)		:=  'You must enter in a Name for the Role.';

ADM_TXT_932	constant varchar2(200)		:=  'Attach Security Roles';
ADM_TXT_933	constant varchar2(200)		:=  'Button Table Pixel Gap Between Cells';
ADM_TXT_934	constant varchar2(200)		:=  'Report Successfully Copied';
ADM_TXT_935	constant varchar2(200)		:=  'Report Deleted';
ADM_TXT_936	constant varchar2(200)		:=  'Parameter Role Options';
ADM_TXT_937	constant varchar2(200)		:=  'Parameter Level';
ADM_TXT_938	constant varchar2(200)		:=  'Modify Meta Tag Details';
ADM_TXT_939	constant varchar2(200)		:=  'Meta Tag Details Successfully Modified';
ADM_TXT_940	constant varchar2(200)		:=  'Instruction Cell Colour';

ADM_TXT_941	constant varchar2(200)		:=  'Instruction Table Border Width';
ADM_TXT_942	constant varchar2(200)		:=  'Instruction Increase Font Size by';
ADM_TXT_943	constant varchar2(200)		:=  'Matte Colour';
ADM_TXT_944	constant varchar2(200)		:=  'Matte Border Colour 3D Dark';
ADM_TXT_945	constant varchar2(200)		:=  'Matte Border Colour 3D Light';
ADM_TXT_946	constant varchar2(200)		:=  'Matte Width in Pixels around Thumbnail';
ADM_TXT_947	constant varchar2(200)		:=  'Matte Border Width in Pixels';
ADM_TXT_948	constant varchar2(200)		:=  'Standard Increase Font by';
ADM_TXT_949	constant varchar2(200)		:=  'Error Text Colour';
ADM_TXT_950	constant varchar2(200)		:=  'Error Text Font';

ADM_TXT_951	constant varchar2(200)		:=  'Instruction Text Colour';
ADM_TXT_952	constant varchar2(200)		:=  'Instruction Text Font';
ADM_TXT_953	constant varchar2(200)		:=  'Instruction Alignment';
ADM_TXT_954	constant varchar2(200)		:=  'Meta Tag Search';
ADM_TXT_955	constant varchar2(200)		:=  'Run Meta Tag Search';
ADM_TXT_956	constant varchar2(200)		:=  'In Case of a Problem you can be contacted on the following Phone Numbers';
ADM_TXT_957	constant varchar2(200)		:=  'Meta Tag Name';
ADM_TXT_959	constant varchar2(200)		:=  'Item';
ADM_TXT_960	constant varchar2(200)		:=  'Item Details';

ADM_TXT_961	constant varchar2(200)		:=  'Include in General STORE option<BR>Display in every Category<BR>Display in some Categories';
ADM_TXT_962	constant varchar2(200)		:=  'Manufacturer Types';
ADM_TXT_963	constant varchar2(200)		:=  'Manufacturer Types Modified';
ADM_TXT_964	constant varchar2(200)		:=  'Modify Manufacturer Types';
ADM_TXT_965	constant varchar2(200)		:=  'Unable to Delete as Manufacturers are mapped to this Manufacturer Type';
ADM_TXT_966	constant varchar2(200)		:=  'Cannot Create new Manufacturer as it already exists';


end lng3;

/
