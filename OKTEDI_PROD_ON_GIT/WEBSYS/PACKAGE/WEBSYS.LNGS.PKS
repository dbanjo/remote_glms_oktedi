CREATE OR REPLACE PACKAGE WEBSYS."LNGS" 
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

STR_DATE_01	constant varchar2(200)		:=  'DD Mon YYYY HH24:MI';
STR_DATE_02	constant varchar2(200)		:=  'DD-MON-YYYY';
STR_DATE_03 constant varchar2(200)    :=  'DD Mon YYYY';
STR_FRMT_03	constant varchar2(200)		:=  '999,999,999.999';
STR_FRMT_04	constant varchar2(200)		:=  '999,999,999';
STR_FRMT_05	constant varchar2(200)		:=  '999,999.99999';
STR_FRMT_06	constant varchar2(200)		:=  '99999999.99';
STR_FRMT_07	constant varchar2(200)		:=  '999,999.999';
STR_FRMT_08	constant varchar2(200)		:=  '999,999.9999999';
MONEY_FORMAT	constant varchar2(200)		:=  '$999,999,990.99';
MONEY_FORMAT2	constant varchar2(200)		:=  '$999999990.99';


STR_TXT_001	constant varchar2(200)		:=  'Manage List of Values';
STR_TXT_002	constant varchar2(200)		:=  'Access Denied';
STR_TXT_002a constant varchar2(200)		:=  'Access Denied - Outbound user can''t delete Inbound PO';
STR_TXT_003	constant varchar2(200)		:=  'Search';
STR_TXT_004	constant varchar2(200)		:=  'Inventory';
STR_TXT_005	constant varchar2(200)		:=  'Tariff';
STR_TXT_006	constant varchar2(200)		:=  'Code';
STR_TXT_007	constant varchar2(200)		:=  'Description';
STR_TXT_008	constant varchar2(200)		:=  'Sub Total';
STR_TXT_009	constant varchar2(200)		:=  'Additional Value';
STR_TXT_010	constant varchar2(200)		:=  'Mass Container Print';

STR_TXT_011	constant varchar2(200)		:=  'Consolidate Measurement';
STR_TXT_012	constant varchar2(200)		:=  'Total';
STR_TXT_013	constant varchar2(200)		:=  'Old Rate';
STR_TXT_014	constant varchar2(200)		:=  'Excise';
STR_TXT_015	constant varchar2(200)		:=  'Modify';
STR_TXT_016	constant varchar2(200)		:=  'Return';
STR_TXT_017	constant varchar2(200)		:=  'Value';
STR_TXT_018	constant varchar2(200)		:=  'already exists';
STR_TXT_019	constant varchar2(200)		:=  'Cannot Delete';
STR_TXT_020	constant varchar2(200)		:=  'it already exists in the PO Table';

STR_TXT_021	constant varchar2(200)		:=  'Records Successfully Inserted';
STR_TXT_022	constant varchar2(200)		:=  'Records Successfully Updated';
STR_TXT_023	constant varchar2(200)		:=  'Receivals';
STR_TXT_024	constant varchar2(200)		:=  'Delivery #';
STR_TXT_025	constant varchar2(200)		:=  'Customer';
STR_TXT_026	constant varchar2(200)		:=  'Date';
STR_TXT_027	constant varchar2(200)		:=  'Supplier';
STR_TXT_028	constant varchar2(200)		:=  'Currency';
STR_TXT_029	constant varchar2(200)		:=  'Exchange Rate';
STR_TXT_030	constant varchar2(200)		:=  'Default GST Code';

STR_TXT_031	constant varchar2(200)		:=  'Insert New Delivery';
STR_TXT_031a constant varchar2(200)		:=  'Manual Delivery';
STR_TXT_032	constant varchar2(200)		:=  'Update Delivery';
STR_TXT_033	constant varchar2(200)		:=  'Delete Delivery';
STR_TXT_034	constant varchar2(200)		:=  'New Receival';
STR_TXT_035	constant varchar2(200)		:=  'New Customer/Supplier';
STR_TXT_036	constant varchar2(200)		:=  'New Supplier';
STR_TXT_037	constant varchar2(200)		:=  'Invalid Date Entered. Must be in format';
STR_TXT_038	constant varchar2(200)		:=  'The Exchange Rate is too large a number';
STR_TXT_039	constant varchar2(200)		:=  'Delivery Record successfully Inserted';
STR_TXT_040	constant varchar2(200)		:=  'Delivery Record Deleted';

STR_TXT_041	constant varchar2(200)		:=  'Delivery Record successfully Updated';
STR_TXT_042	constant varchar2(200)		:=  'Please Enter in Receival Details';
STR_TXT_043	constant varchar2(200)		:=  'Update Detail';
STR_TXT_044	constant varchar2(200)		:=  'Insert New Detail';
STR_TXT_045	constant varchar2(200)		:=  'Item #';
STR_TXT_046	constant varchar2(200)		:=  'Log No';
STR_TXT_047	constant varchar2(200)		:=  'Use Todays';
STR_TXT_048	constant varchar2(200)		:=  'Create New';
STR_TXT_049	constant varchar2(200)		:=  'Air or Sea';
STR_TXT_050	constant varchar2(200)		:=  'Air';

STR_TXT_051	constant varchar2(200)		:=  'Sea';
STR_TXT_052	constant varchar2(200)		:=  'C or L';
STR_TXT_053	constant varchar2(200)		:=  'C';
STR_TXT_054	constant varchar2(200)		:=  'L';
STR_TXT_055	constant varchar2(200)		:=  'Qty';
STR_TXT_056	constant varchar2(200)		:=  'Pack Type';
STR_TXT_057	constant varchar2(200)		:=  'Weight (Kg)';
STR_TXT_058	constant varchar2(200)		:=  'Volume (m3)';
STR_TXT_059	constant varchar2(200)		:=  'Description';
STR_TXT_060	constant varchar2(200)		:=  'ECN';

STR_TXT_061	constant varchar2(200)		:=  'Hazard';
STR_TXT_062	constant varchar2(200)		:=  'Movement No';
STR_TXT_063	constant varchar2(200)		:=  'Seal';
STR_TXT_064	constant varchar2(200)		:=  'Entry No';
STR_TXT_065	constant varchar2(200)		:=  'Line No';
STR_TXT_066	constant varchar2(200)		:=  'HAWB';
STR_TXT_067	constant varchar2(200)		:=  'Save_Record';
STR_TXT_068	constant varchar2(200)		:=  'Insert_Record';
STR_TXT_069	constant varchar2(200)		:=  'Split_Record';
STR_TXT_070	constant varchar2(200)		:=  'Delete_Record';

STR_TXT_071	constant varchar2(200)		:=  'Previous_Record';
STR_TXT_072	constant varchar2(200)		:=  'Next_Record';
STR_TXT_073	constant varchar2(200)		:=  'Record Deleted';
STR_TXT_074	constant varchar2(200)		:=  'Invalid Item No';
STR_TXT_075	constant varchar2(200)		:=  'Item No and Log No already exists';
STR_TXT_076	constant varchar2(200)		:=  'Invalid Number Entered for Part Volume';
STR_TXT_077	constant varchar2(200)		:=  'Invalid Number Entered for Part Weight';
STR_TXT_078	constant varchar2(200)		:=  'Invalid Number Entered for Quantity';
STR_TXT_079	constant varchar2(200)		:=  'Error on Insert';
STR_TXT_080	constant varchar2(200)		:=  'Error on Update';

STR_TXT_081	constant varchar2(200)		:=  'Record Saved';
STR_TXT_082	constant varchar2(200)		:=  'Split Detailr Record';
STR_TXT_083	constant varchar2(200)		:=  'Quantity';
STR_TXT_084	constant varchar2(200)		:=  'Automatic';
STR_TXT_085	constant varchar2(200)		:=  'Manual';
STR_TXT_086	constant varchar2(200)		:=  'Split Detailr Record';
STR_TXT_087	constant varchar2(200)		:=  'Invalid Split Number. Operation Cancelled';
STR_TXT_088	constant varchar2(200)		:=  'Split Number Greater than Quantity. Operation Cancelled';
STR_TXT_089	constant varchar2(200)		:=  'Manual Split Detailr Record';
STR_TXT_090	constant varchar2(200)		:=  'Weight';

STR_TXT_091	constant varchar2(200)		:=  'Volume';
STR_TXT_092	constant varchar2(200)		:=  'Manual Split';
STR_TXT_093	constant varchar2(200)		:=  'Records Split';
STR_TXT_094	constant varchar2(200)		:=  'Please Enter in Receival Details';
STR_TXT_095	constant varchar2(200)		:=  'Update Purchase Order';
STR_TXT_096	constant varchar2(200)		:=  'Insert New Purchase Order';
STR_TXT_097	constant varchar2(200)		:=  'Record No';
STR_TXT_098	constant varchar2(200)		:=  'Purchase Order';
STR_TXT_099	constant varchar2(200)		:=  'Supplier Inv';
STR_TXT_100	constant varchar2(200)		:=  'Material No.';

STR_TXT_101	constant varchar2(200)		:=  'Unit';
STR_TXT_102	constant varchar2(200)		:=  'Country';
STR_TXT_103	constant varchar2(200)		:=  'GST Code';
STR_TXT_104	constant varchar2(200)		:=  'Amount';
STR_TXT_105	constant varchar2(200)		:=  'GST';
STR_TXT_106	constant varchar2(200)		:=  'Total Amount';
STR_TXT_107	constant varchar2(200)		:=  'Copy_Record';
STR_TXT_108	constant varchar2(200)		:=  'This Record already exists';
STR_TXT_109	constant varchar2(200)		:=  'Invalid Number Entered for Quantity';
STR_TXT_109e	constant varchar2(200)		:=  'Invalid Number Entered for Excise Quantity';
STR_TXT_110	constant varchar2(200)		:=  'Invalid Number Entered for Amount';

STR_TXT_111	constant varchar2(200)		:=  'Invalid Number Entered for Total Amount';
STR_TXT_112	constant varchar2(200)		:=  'Invalid Number Entered for GST';
STR_TXT_113	constant varchar2(200)		:=  'Warning: GST is inclusive. You should not specify GST';
STR_TXT_114	constant varchar2(200)		:=  'Warning: GST is exempt. You should not specify GST';
STR_TXT_115	constant varchar2(200)		:=  'Warning: NET Amount Specified. You should specify Amount';
STR_TXT_116	constant varchar2(200)		:=  'Warning: GST is inclusive. You should not specify amount.';
STR_TXT_117	constant varchar2(200)		:=  'Warning: GST is inclusive. You should specify Total Amount';
STR_TXT_118	constant varchar2(200)		:=  'Warning: NET Amount Specified. You should not specify Total Amount';
STR_TXT_119	constant varchar2(200)		:=  'Cargo Movements';
STR_TXT_120	constant varchar2(200)		:=  'Consignment Note Movements';

STR_TXT_121	constant varchar2(200)		:=  'Air Freight Movements';
STR_TXT_122	constant varchar2(200)		:=  'Container #';
STR_TXT_123	constant varchar2(200)		:=  'Consignment';
STR_TXT_124	constant varchar2(200)		:=  'MAWB';
STR_TXT_125	constant varchar2(200)		:=  'Carrier and Flight';
STR_TXT_126	constant varchar2(200)		:=  'Ship and Voyage';
STR_TXT_127	constant varchar2(200)		:=  'Assign BOL';
STR_TXT_128	constant varchar2(200)		:=  'Assign ECN';
STR_TXT_129	constant varchar2(200)		:=  'Carrier';
STR_TXT_130	constant varchar2(200)		:=  'Packing List';

STR_TXT_131	constant varchar2(200)		:=  'INCOMPLETE';
STR_TXT_132	constant varchar2(200)		:=  'PACKING COMPLETE';
STR_TXT_133	constant varchar2(200)		:=  'ARRIVED AT PORT';
STR_TXT_134	constant varchar2(200)		:=  'DESPATCHED';
STR_TXT_135	constant varchar2(200)		:=  'Invoice';
STR_TXT_136	constant varchar2(200)		:=  'Cascade Update';
STR_TXT_137	constant varchar2(200)		:=  'Container Type';
STR_TXT_138	constant varchar2(200)		:=  'Tare(Kg)';
STR_TXT_139	constant varchar2(200)		:=  'Dispatch Date';
STR_TXT_140	constant varchar2(200)		:=  'Departure Date';
STR_TXT_140a constant varchar2(200)		:=  'Arrival Date';

STR_TXT_141	constant varchar2(200)		:=  'Departure Location';
STR_TXT_142	constant varchar2(200)		:=  'Arrival Location';
STR_TXT_143	constant varchar2(200)		:=  'BOL';
STR_TXT_144	constant varchar2(200)		:=  'Comments';
STR_TXT_145	constant varchar2(200)		:=  'Number of New Movements';
STR_TXT_146	constant varchar2(200)		:=  'Deassign';
STR_TXT_147	constant varchar2(200)		:=  'Revenue Tonne';
STR_TXT_148	constant varchar2(200)		:=  'Chargeable Weight';
STR_TXT_149	constant varchar2(200)		:=  'Insert New Movement';
STR_TXT_150	constant varchar2(200)		:=  'Update Movement';

STR_TXT_151	constant varchar2(200)		:=  'Delete';
STR_TXT_152	constant varchar2(200)		:=  'Invalid Date Entered';
STR_TXT_153	constant varchar2(200)		:=  'must be of format';
STR_TXT_154	constant varchar2(200)		:=  'Invalid Tare Entered';
STR_TXT_155	constant varchar2(200)		:=  'A Movement Number must be entered';
STR_TXT_156	constant varchar2(200)		:=  'A Cargo Seal must be entered';
STR_TXT_157	constant varchar2(200)		:=  'New Record Successfully Deleted';
STR_TXT_158	constant varchar2(200)		:=  'The Movement Number and Seal must be Unique. This value already exists';
STR_TXT_158a constant varchar2(200)		:=  'The Movement Number and Seal cannot be deleted. Delivery items already exist';
STR_TXT_159	constant varchar2(200)		:=  'The Movement Number must be Unique. This value already exists';
STR_TXT_160	constant varchar2(200)		:=  'New Record Successfully Inserted';
STR_TXT_160a constant varchar2(200)		:=  'Parent container successfully inserted. Please fill in details and press the insert button to proceed';
STR_TXT_160b constant varchar2(200)		:=  'Parent container successfully inserted. Please verify the details and press the insert button to proceed';

STR_TXT_161	constant varchar2(200)		:=  'Record Successfully Updated';
STR_TXT_162	constant varchar2(200)		:=  'Mass Movement Entry';
STR_TXT_163	constant varchar2(200)		:=  'Delivery No';
STR_TXT_164	constant varchar2(200)		:=  'Item No';
STR_TXT_164a constant varchar2(200)		:=  'Unit No';
STR_TXT_165	constant varchar2(200)		:=  'Insert New Movements';
STR_TXT_166	constant varchar2(200)		:=  'Records Successfully Inserted';
STR_TXT_167	constant varchar2(200)		:=  'Ship/Air Management';
STR_TXT_168	constant varchar2(200)		:=  'Ship / Air';
STR_TXT_169	constant varchar2(200)		:=  'Ship';
STR_TXT_170	constant varchar2(200)		:=  'Ship Name / MAWB';

STR_TXT_171	constant varchar2(200)		:=  'Voyage / Flight';
STR_TXT_172	constant varchar2(200)		:=  'Status';
STR_TXT_173	constant varchar2(200)		:=  'Estimated Departure';
STR_TXT_174	constant varchar2(200)		:=  'Departure Location';
STR_TXT_175	constant varchar2(200)		:=  'Estimated Arrival';
STR_TXT_176	constant varchar2(200)		:=  'Arrival Location';
STR_TXT_177	constant varchar2(200)		:=  'Agent';
STR_TXT_178	constant varchar2(200)		:=  'Country of Origin';
STR_TXT_179	constant varchar2(200)		:=  'Master / Pilot';
STR_TXT_180	constant varchar2(200)		:=  'Australian Crew';

STR_TXT_181	constant varchar2(200)		:=  'PNG Crew';
STR_TXT_182	constant varchar2(200)		:=  'Foreign Crew';
STR_TXT_183	constant varchar2(200)		:=  'Final Destination';
STR_TXT_184	constant varchar2(200)		:=  'Insert New Ship/Air';
STR_TXT_185	constant varchar2(200)		:=  'Update Ship/Air';
STR_TXT_186	constant varchar2(200)		:=  'Create New Ship/Air';
STR_TXT_187	constant varchar2(200)		:=  'Delete Ship/Air';
STR_TXT_188	constant varchar2(200)		:=  'Customs Info';
STR_TXT_189	constant varchar2(200)		:=  'Ships/Airway Deleted';
STR_TXT_190	constant varchar2(200)		:=  'Departure Date must be less than Arrival Date';

STR_TXT_191	constant varchar2(200)		:=  'Invalid Weight Entered';
STR_TXT_192	constant varchar2(200)		:=  'Invalid Australian Crew Entered';
STR_TXT_193	constant varchar2(200)		:=  'Invalid PNG Crew Entered';
STR_TXT_194	constant varchar2(200)		:=  'Invalid Foreign Entered' ;
STR_TXT_195	constant varchar2(200)		:=  'must be a whole number';
STR_TXT_196	constant varchar2(200)		:=  'A Ship Name must be Entered';
STR_TXT_197	constant varchar2(200)		:=  'A Voyage must be Entered';
STR_TXT_198	constant varchar2(200)		:=  'Customs Information';
STR_TXT_199	constant varchar2(200)		:=  'Port From';
STR_TXT_200	constant varchar2(200)		:=  'Licence No';

STR_TXT_201	constant varchar2(200)		:=  'P2a Code';
STR_TXT_202	constant varchar2(200)		:=  'CPC';
STR_TXT_203	constant varchar2(200)		:=  'Comparative Worksheet';
STR_TXT_204	constant varchar2(200)		:=  'Account Number';
STR_TXT_205	constant varchar2(200)		:=  'Preceding Documents';
STR_TXT_206	constant varchar2(200)		:=  'Terms of Delivery';
STR_TXT_207	constant varchar2(200)		:=  'Attachments';
STR_TXT_208	constant varchar2(200)		:=  'Invoices';
STR_TXT_209	constant varchar2(200)		:=  'Packing';
STR_TXT_210	constant varchar2(200)		:=  'Order';

STR_TXT_211	constant varchar2(200)		:=  'Licence';
STR_TXT_212	constant varchar2(200)		:=  'Freight';
STR_TXT_213	constant varchar2(200)		:=  'Other';
STR_TXT_214	constant varchar2(200)		:=  'Rate';
STR_TXT_215	constant varchar2(200)		:=  'Insurance';
STR_TXT_216	constant varchar2(200)		:=  'Vat';
STR_TXT_217	constant varchar2(200)		:=  'Other Costs';
STR_TXT_218	constant varchar2(200)		:=  'Update Customs Info';
STR_TXT_219	constant varchar2(200)		:=  'Ships/Airway';
STR_TXT_220	constant varchar2(200)		:=  'Return to Ships/Airway';

STR_TXT_221	constant varchar2(200)		:=  'Invalid Rate Entered';
STR_TXT_222	constant varchar2(200)		:=  'Invalid Freight Entered';
STR_TXT_223	constant varchar2(200)		:=  'Invalid Insurance Entered';
STR_TXT_224	constant varchar2(200)		:=  'Invalid Vat Entered';
STR_TXT_225	constant varchar2(200)		:=  'Invalid Other Costs Entered';
STR_TXT_226	constant varchar2(200)		:=  'Invoicing';
STR_TXT_227	constant varchar2(200)		:=  'Inv Number';
STR_TXT_228	constant varchar2(200)		:=  'Contract';
STR_TXT_229	constant varchar2(200)		:=  'Inv Date';
STR_TXT_230	constant varchar2(200)		:=  'Billing Month';

STR_TXT_231	constant varchar2(200)		:=  'Billing Year';
STR_TXT_232	constant varchar2(200)		:=  'Charge Code';
STR_TXT_233	constant varchar2(200)		:=  'Sub GST';
STR_TXT_234	constant varchar2(200)		:=  'Insert New Invoice';
STR_TXT_235	constant varchar2(200)		:=  'Update Invoice';
STR_TXT_236	constant varchar2(200)		:=  'Invoice List';
STR_TXT_237	constant varchar2(200)		:=  'Delete Invoice';
STR_TXT_238	constant varchar2(200)		:=  'An Invoice Number must be Entered';
STR_TXT_239	constant varchar2(200)		:=  'A Contract must be Entered';
STR_TXT_240	constant varchar2(200)		:=  'An Invoice Date must be Entered';

STR_TXT_241	constant varchar2(200)		:=  'This invoice number already exists';
STR_TXT_242	constant varchar2(200)		:=  'No Description';
STR_TXT_243	constant varchar2(200)		:=  'New Invoice Successfully Inserted';
STR_TXT_244	constant varchar2(200)		:=  'Revenue Tonne (REVTON)';
STR_TXT_245	constant varchar2(200)		:=  'Gross Weight';
STR_TXT_246	constant varchar2(200)		:=  '(Containers Only - Including Tare)';
STR_TXT_247	constant varchar2(200)		:=  '(Airfreight Only)';
STR_TXT_248	constant varchar2(200)		:=  'Container No';
STR_TXT_249	constant varchar2(200)		:=  'Connote';
STR_TXT_250	constant varchar2(200)		:=  'Display Invoice Details';

STR_TXT_251	constant varchar2(200)		:=  'Update Invoice List';
STR_TXT_252	constant varchar2(200)		:=  'Invoice Details';
STR_TXT_253	constant varchar2(200)		:=  'No Modification Made';
STR_TXT_254	constant varchar2(200)		:=  'Assigning HAWB values';
STR_TXT_255	constant varchar2(200)		:=  'Search for MAWB';
STR_TXT_256	constant varchar2(200)		:=  'HAWB No';
STR_TXT_257	constant varchar2(200)		:=  'No MAWB found.';
STR_TXT_258	constant varchar2(200)		:=  'Add new HAWB Values';
STR_TXT_259	constant varchar2(200)		:=  'Modify HAWB Values';
STR_TXT_260	constant varchar2(200)		:=  'HAWB Values Successfully Assigned';

STR_TXT_261	constant varchar2(200)		:=  'Assigning BOLs to Containers';
STR_TXT_262	constant varchar2(200)		:=  'No Ship found. Try another Search';
STR_TXT_263	constant varchar2(200)		:=  'Modify BOL Assignment';
STR_TXT_264	constant varchar2(200)		:=  'Repeat First Value for All';
STR_TXT_265	constant varchar2(200)		:=  'BOL Values Successfully Assigned';
STR_TXT_266	constant varchar2(200)		:=  'Assigning ECN Values to Containers';
STR_TXT_267	constant varchar2(200)		:=  'Modify ECN Assignment';
STR_TXT_268	constant varchar2(200)		:=  'ECN Values Successfully Assigned';
STR_TXT_269	constant varchar2(200)		:=  'Assigning Air Freight ECNs & Handling Units';
STR_TXT_270	constant varchar2(200)		:=  'List of MAWBS';

STR_TXT_271	constant varchar2(200)		:=  'Assigning Movement to Delivery';
STR_TXT_272	constant varchar2(200)		:=  'Consignment Note';
STR_TXT_273	constant varchar2(200)		:=  'Container Number';
STR_TXT_274	constant varchar2(200)		:=  'Airway';
STR_TXT_275	constant varchar2(200)		:=  'Flight';
STR_TXT_276	constant varchar2(200)		:=  'Voyage';
STR_TXT_277	constant varchar2(200)		:=  'Update';
STR_TXT_278	constant varchar2(200)		:=  'Check All';
STR_TXT_279	constant varchar2(200)		:=  'Uncheck All';
STR_TXT_280	constant varchar2(200)		:=  'Assignment Successfully Completed';

STR_TXT_281	constant varchar2(200)		:=  'Cascade Update Movement No';
STR_TXT_282	constant varchar2(200)		:=  'Movement Type';
STR_TXT_283	constant varchar2(200)		:=  'Old Movement ID';
STR_TXT_284	constant varchar2(200)		:=  'Old SEAL';
STR_TXT_285	constant varchar2(200)		:=  'New Movement ID';
STR_TXT_286	constant varchar2(200)		:=  'New SEAL';
STR_TXT_287	constant varchar2(200)		:=  'Perform Cascade Update';
STR_TXT_288	constant varchar2(200)		:=  'Receivals Search on';
STR_TXT_289	constant varchar2(200)		:=  'No Results found from Search.';
STR_TXT_290	constant varchar2(200)		:=  'Hit the BACK Button and retry your Search.';

STR_TXT_291	constant varchar2(200)		:=  'Movement Search on';
STR_TXT_292	constant varchar2(200)		:=  'Inventory Search on';
STR_TXT_293	constant varchar2(200)		:=  'Duty Search on';
STR_TXT_294	constant varchar2(200)		:=  'Ships/Airway Search on';
STR_TXT_295	constant varchar2(200)		:=  'Duty Management';
STR_TXT_296	constant varchar2(200)		:=  'Warrant No';
STR_TXT_297	constant varchar2(200)		:=  'Cheque';
STR_TXT_298	constant varchar2(200)		:=  'Total Invoice';
STR_TXT_299	constant varchar2(200)		:=  'Duty';
STR_TXT_300	constant varchar2(200)		:=  'Ratio Factor';

STR_TXT_301	constant varchar2(200)		:=  'Correct Freight';
STR_TXT_302	constant varchar2(200)		:=  'Previous Internal No';
STR_TXT_303	constant varchar2(200)		:=  'Excise';
STR_TXT_304	constant varchar2(200)		:=  'PVariance';
STR_TXT_305	constant varchar2(200)		:=  'Insert New Duty';
STR_TXT_306	constant varchar2(200)		:=  'Update Duty';
STR_TXT_307	constant varchar2(200)		:=  'Duty Record Successfully Updated';
STR_TXT_308	constant varchar2(200)		:=  'Report Not Found';
STR_TXT_309	constant varchar2(200)		:=  'Controlling Office';
STR_TXT_310	constant varchar2(200)		:=  'Assign';

STR_TXT_311	constant varchar2(200)		:=  'Generate Entry Nos';
STR_TXT_312	constant varchar2(200)		:=  'Duty Details Generated';
STR_TXT_313	constant varchar2(200)		:=  'Generate Line Nos';
STR_TXT_314	constant varchar2(200)		:=  'Unallocate Entry Nos';
STR_TXT_315	constant varchar2(200)		:=  'Line Nos Generated';
STR_TXT_316	constant varchar2(200)		:=  'Details Unallocated';
STR_TXT_317	constant varchar2(200)		:=  'Number of Splits';
STR_TXT_318	constant varchar2(200)		:=  'Cancel';
STR_TXT_319	constant varchar2(200)		:=  'Records Split';
STR_TXT_320	constant varchar2(200)		:=  'Action Cancelled';

STR_TXT_321	constant varchar2(200)		:=  'Manage Customer Details';
STR_TXT_322	constant varchar2(200)		:=  'Insert New Customer';
STR_TXT_323	constant varchar2(200)		:=  'Update Customer';
STR_TXT_324	constant varchar2(200)		:=  'Customer Id';
STR_TXT_325	constant varchar2(200)		:=  'Customer Name';
STR_TXT_326	constant varchar2(200)		:=  'Street';
STR_TXT_327	constant varchar2(200)		:=  'Suburb';
STR_TXT_328	constant varchar2(200)		:=  'State';
STR_TXT_329	constant varchar2(200)		:=  'Postcode';
STR_TXT_330	constant varchar2(200)		:=  'City';

STR_TXT_331	constant varchar2(200)		:=  'Country';
STR_TXT_332	constant varchar2(200)		:=  'ABN';
STR_TXT_333	constant varchar2(200)		:=  'Email';
STR_TXT_334	constant varchar2(200)		:=  'Phone';
STR_TXT_335	constant varchar2(200)		:=  'Fax';
STR_TXT_336	constant varchar2(200)		:=  'Type of Customer';
STR_TXT_337	constant varchar2(200)		:=  'Delete Customer';
STR_TXT_338	constant varchar2(200)		:=  'This Customer already exists';
STR_TXT_339	constant varchar2(200)		:=  'New Customer Successfully Inserted';
STR_TXT_340	constant varchar2(200)		:=  'Customer Successfully Updated';

STR_TXT_341	constant varchar2(200)		:=  'Customer Name must be Specified';
STR_TXT_342	constant varchar2(200)		:=  'Quantity total does not match';
STR_TXT_343	constant varchar2(200)		:=  'Weight total does not match';
STR_TXT_344	constant varchar2(200)		:=  'Volume total does not match';
STR_TXT_345	constant varchar2(200)		:=  'For Tariff, values must exist for Rate, Old Rate and Excise';
STR_TXT_346	constant varchar2(200)		:=  'This Tariff code does not exist in the Tariff Table';
STR_TXT_347	constant varchar2(200)		:=  'Where there are no Inventory Nos';
STR_TXT_348	constant varchar2(200)		:=  'Where the Inventory Nos do not exist in the Inventory table';
STR_TXT_349	constant varchar2(200)		:=  'Inventory No';
STR_TXT_350	constant varchar2(200)		:=  'Where the Inventory Nos do not have a corresponding Tariff No';

STR_TXT_351	constant varchar2(200)		:=  'Inventory Description';
STR_TXT_352	constant varchar2(200)		:=  'Where the Inventory Nos Tariff Nos are not in the Tariff Table';
STR_TXT_353	constant varchar2(200)		:=  'Inventory Tariff No';
STR_TXT_354	constant varchar2(200)		:=  'Where the Purchase Order Unit Used does not match the Tariff Unit Used';
STR_TXT_355	constant varchar2(200)		:=  'Purchase Unit Used';
STR_TXT_356	constant varchar2(200)		:=  'Tariff Unit Used';
STR_TXT_357	constant varchar2(200)		:=  'Insert New Values';
STR_TXT_358	constant varchar2(200)		:=  'Modify Values';
STR_TXT_359	constant varchar2(200)		:=  'Cancel';
STR_TXT_360	constant varchar2(200)		:=  'Invalid Pack Type Entered';

STR_TXT_361	constant varchar2(200)		:=  'Are You Sure you want to Delete this Record?';
STR_TXT_362	constant varchar2(200)		:=  'Receival Deletion Cancelled';
STR_TXT_364	constant varchar2(200)		:=  'No Movements Found';
STR_TXT_365	constant varchar2(200)		:=  'GST Type';
STR_TXT_366	constant varchar2(200)		:=  'No GST';
STR_TXT_367	constant varchar2(200)		:=  'Inc GST';
STR_TXT_368	constant varchar2(200)		:=  'Add GST';
STR_TXT_369	constant varchar2(200)		:=  'Manage Charge Codes';
STR_TXT_370	constant varchar2(200)		:=  'Charge Code must be Specified';

STR_TXT_371	constant varchar2(200)		:=  'This Charge Code already exists';
STR_TXT_372	constant varchar2(200)		:=  'Delete Charge Code';
STR_TXT_373	constant varchar2(200)		:=  'Insert New Charge Code';
STR_TXT_374	constant varchar2(200)		:=  'Update Charge Code';
STR_TXT_375	constant varchar2(200)		:=  'Charge Code Search on';
STR_TXT_376	constant varchar2(200)		:=  'Charge Code Description';
STR_TXT_377	constant varchar2(200)		:=  'Cost Code';
STR_TXT_378	constant varchar2(200)		:=  'Charge Code Successfully Updated';
STR_TXT_379	constant varchar2(200)		:=  'Invalid Unit Entered';
STR_TXT_380	constant varchar2(200)		:=  'HAWB Values';

STR_TXT_381	constant varchar2(200)		:=  'Manifest Description';
STR_TXT_382	constant varchar2(200)		:=  'State';
STR_TXT_383	constant varchar2(200)		:=  'Country';
STR_TXT_384	constant varchar2(200)		:=  'Hot Sync';
STR_TXT_385	constant varchar2(200)		:=  'Table';
STR_TXT_386	constant varchar2(200)		:=  'Allowed Change';
STR_TXT_387	constant varchar2(200)		:=  'Synchronisation Type';
STR_TXT_388	constant varchar2(200)		:=  'Refresh Changed Rows Only';
STR_TXT_389	constant varchar2(200)		:=  'Complete Refresh. Will Delete all Data in Current Database and Refresh from Master Site.';
STR_TXT_390	constant varchar2(200)		:=  'Run HotSync';

STR_TXT_391	constant varchar2(200)		:=  'Success';
STR_TXT_392	constant varchar2(200)		:=  'Generate HAWBs';
STR_TXT_393	constant varchar2(200)		:=  'HAWBs Successfully Generated';
STR_TXT_394	constant varchar2(200)		:=  'Airway MAWB';
STR_TXT_395	constant varchar2(200)		:=  'Shipper ID';
STR_TXT_396	constant varchar2(200)		:=  'Notify Party Customer ID';
STR_TXT_397	constant varchar2(200)		:=  'Nationality of the Master';
STR_TXT_398	constant varchar2(200)		:=  'Print Invoice';
STR_TXT_399	constant varchar2(200)		:=  'New Charge Code Successfully Inserted';
STR_TXT_400	constant varchar2(200)		:=  'Confirm Deletion of this Invoice';

STR_TXT_401	constant varchar2(200)		:=  'Invoice Deleted';
STR_TXT_402	constant varchar2(200)		:=  'Debug Enabled';
STR_TXT_403	constant varchar2(200)		:=  'HotSync Analysis';
STR_TXT_404	constant varchar2(200)		:=  'Cull Rows from Replication Table';
STR_TXT_405	constant varchar2(200)		:=  'Before Date';
STR_TXT_406	constant varchar2(200)		:=  'This Ship/Airway Record already exists';
STR_TXT_407	constant varchar2(200)		:=  'A Record with this Movement Number already exists';
STR_TXT_408	constant varchar2(200)		:=  'A Record with this Charge Number already exists';
STR_TXT_409	constant varchar2(200)		:=  'Assign ECN/HU by Log';
STR_TXT_410	constant varchar2(200)		:=  'First_Record';

STR_TXT_411	constant varchar2(200)		:=  'Last_Record';
STR_TXT_412	constant varchar2(200)		:=  'Return to Previous Screen';
STR_TXT_413	constant varchar2(200)		:=  'Confirm Allocation';
STR_TXT_414	constant varchar2(200)		:=  'Confirm Unallocation';
STR_TXT_415	constant varchar2(200)		:=  'Action not performed';
STR_TXT_416	constant varchar2(200)		:=  'Local Cargo';
STR_TXT_417	constant varchar2(200)		:=  'All Cargo';
STR_TXT_418	constant varchar2(200)		:=  'All Boxes Checked';
STR_TXT_419	constant varchar2(200)		:=  'All Boxes Unchecked';
STR_TXT_420	constant varchar2(200)		:=  'Hit the Back Button and try a different number';

STR_TXT_421	constant varchar2(200)		:=  'Purchase<BR>Order No';
STR_TXT_422	constant varchar2(200)		:=  'Supplier<BR>Invoice No';
STR_TXT_423	constant varchar2(200)		:=  'Daily<BR>Receival Log<BR>Delivery No';
STR_TXT_424	constant varchar2(200)		:=  'Item No';
STR_TXT_425	constant varchar2(200)		:=  'Date<BR>Received';
STR_TXT_426	constant varchar2(200)		:=  'Strang<BR>Depot';
STR_TXT_427	constant varchar2(200)		:=  'Mode of<BR>Transport';
STR_TXT_428	constant varchar2(200)		:=  'Status';
STR_TXT_429	constant varchar2(200)		:=  'Vessel and<BR>Voyage';
STR_TXT_430	constant varchar2(200)		:=  'Ship Manifest<BR>Line No';

STR_TXT_431	constant varchar2(200)		:=  'Container No';
STR_TXT_432	constant varchar2(200)		:=  'Connote No';
STR_TXT_433	constant varchar2(200)		:=  'MAWB #';
STR_TXT_434	constant varchar2(200)		:=  'HAWB #';
STR_TXT_435	constant varchar2(200)		:=  'Date of<BR>Despatch';
STR_TXT_436	constant varchar2(200)		:=  'ETA<BR>Destination';
STR_TXT_437	constant varchar2(200)		:=  'Search by';
STR_TXT_438	constant varchar2(200)		:=  'Purchase Order Number';
STR_TXT_439	constant varchar2(200)		:=  'Supplier Invoice Number';
STR_TXT_440	constant varchar2(200)		:=  'Supplier Name';

STR_TXT_441	constant varchar2(200)		:=  'Run Search';
STR_TXT_442	constant varchar2(200)		:=  'Enter one or more of the search criteria. The % sign can be used as a wild char.';
STR_TXT_443	constant varchar2(200)		:=  'Strang QuickTrac Worldiwde Cargo Tracking Facility';
STR_TXT_444	constant varchar2(200)		:=  'Strang QuickTrac';
STR_TXT_445	constant varchar2(200)		:=  'Search Results';
STR_TXT_446	constant varchar2(200)		:=  'Worldwide Cargo Tracking Facility';
STR_TXT_447	constant varchar2(200)		:=  'Enter one or more of the search criteria. The % sign can be used as a wild char.';
STR_TXT_448	constant varchar2(200)		:=  'Manual Entry - Header Details';
STR_TXT_449	constant varchar2(200)		:=  'Manual Entry Number';
STR_TXT_450	constant varchar2(200)		:=  'Do not Delete';

STR_TXT_451	constant varchar2(200)		:=  'Entry Number cannot be empty';
STR_TXT_452	constant varchar2(200)		:=  'Delete Manual Entry Tariff';
STR_TXT_453	constant varchar2(200)		:=  'Delete this Record';
STR_TXT_454	constant varchar2(200)		:=  'Manual Entry - Header Details';
STR_TXT_455	constant varchar2(200)		:=  'Manual Record Updated';
STR_TXT_456	constant varchar2(200)		:=  'Insert New Manual Entry Tariff';
STR_TXT_457	constant varchar2(200)		:=  'Header Details';
STR_TXT_458	constant varchar2(200)		:=  'Package Description';
STR_TXT_459	constant varchar2(200)		:=  'Tariff Groups';
STR_TXT_460	constant varchar2(200)		:=  'Create New Entry';
STR_TXT_461     constant varchar2(200)          :=  'Generate OST 185';
STR_TXT_462     constant varchar2(200)          :=  'OST 185 Batch';
STR_TXT_463     constant varchar2(200)		:=  'Insert New Movement as Copy';

STR_STH_001 constant varchar2(200)    :=  'SOUTHBOUND';
STR_STH_002 constant varchar2(200)    :=  'Insert Bill of Lading';
STR_STH_003 constant varchar2(200)    :=  'Update Bill of Lading';
STR_STH_004 constant varchar2(200)    :=  'Delete Record';
STR_STH_005 constant varchar2(200)    :=  'List All Records';
STR_STH_006 constant varchar2(200)    :=  'Edit Bill of Lading';
STR_STH_007 constant varchar2(200)    :=  'Insert Another Bill of Lading';
STR_STH_008 constant varchar2(200)    :=  'Edit Containers';
STR_STH_009 constant varchar2(200)    :=  'Edit DANs';
STR_STH_010 constant varchar2(200)    :=  'Invalid Number Entered';
STR_STH_011 constant varchar2(200)    :=  'Cancel';
STR_STH_012 constant varchar2(200)    :=  'Edit House Bills';
STR_STH_013 constant varchar2(200)    :=  'SOUTHBOUND-PREALERT';
STR_STH_014 constant varchar2(200)    :=  'Break-Bulk DANS';
STR_STH_015 constant varchar2(200)    :=  'Rename Bill of Lading';
STR_STH_016 constant varchar2(200)    :=  'Confirm Rename';
STR_STH_017 constant varchar2(200)    :=  'Multiple Container Maintain';
STR_STH_018 constant varchar2(200)    :=  'Allocate Bills of Lading';
STR_STH_019 constant varchar2(200)    :=  'Allocate House Bills to Container/BBulk';
STR_STH_020 constant varchar2(200)    :=  'Allocate House Bills to Contents';
STR_STH_021 constant varchar2(200)    :=  'Update House Bill';
STR_STH_022 constant varchar2(200)    :=  'Insert Another House Bill';
STR_STH_023 constant varchar2(200)    :=  'Insert House Bill';
STR_STH_024 constant varchar2(200)    :=  'List of Bills of Lading for Ship';
STR_STH_025 constant varchar2(200)    :=  'House Bills for Bill of Lading';
STR_STH_026 constant varchar2(200)    :=  'Reallocate Bills of Lading';
STR_STH_027 constant varchar2(200)    :=  'Repeat House Bill From First Row';
STR_STH_028	constant varchar2(200)	  :=  'Assign Bill of Lading';
STR_STH_029	constant varchar2(200)	  :=  'Assign Local Bill of Lading';

STR_STH_030	constant varchar2(200)		:=  'Manage SMP Details';
STR_STH_031	constant varchar2(200)		:=  'Insert New SMP';
STR_STH_032	constant varchar2(200)		:=  'Update SMP';
STR_STH_033	constant varchar2(200)		:=  'SMP Id';
STR_STH_034	constant varchar2(200)		:=  'SMP No';
STR_STH_035	constant varchar2(200)		:=  'SMP Description';
STR_STH_036	constant varchar2(200)		:=  'SMP Current Location';
STR_STH_037	constant varchar2(200)		:=  'SMP Final Destination';
STR_STH_038	constant varchar2(200)		:=  'SMP Completion Status';
STR_STH_039	constant varchar2(200)		:=  'SMP Mode of Transport';
STR_STH_040	constant varchar2(200)		:=  'Delete SMP';
STR_STH_041	constant varchar2(200)		:=  'SMP No. must be Specified';
STR_STH_042	constant varchar2(200)		:=  'This SMP already exists';
STR_STH_043	constant varchar2(200)		:=  'New SMP Successfully Inserted';
STR_STH_044	constant varchar2(200)		:=  'SMP Successfully Updated';
STR_STH_045	constant varchar2(200)		:=  'This SMP already exists';
STR_STH_046 constant varchar2(200)		:=  'SMP cannot be deleted. Delivery items already attached';
STR_STH_047 constant varchar2(200)		:=  'SMP deleted';
end lngs;
/


GRANT EXECUTE ON WEBSYS.LNGS TO STX1;
