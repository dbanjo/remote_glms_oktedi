CREATE OR REPLACE package WEBSYS.lng4
as

--
-- English Language Module #4
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
-- Adhoc Text Messages belonging to any Package
--

AHC_TXT_001	constant varchar2(200)		:=  'Request for Quote Management';
AHC_TXT_002	constant varchar2(200)		:=  'Quote / Reference';
AHC_TXT_004	constant varchar2(200)		:=  'Create New Request for Quote';
AHC_TXT_005	constant varchar2(200)		:=  'Insert New Request for Quote';
AHC_TXT_006	constant varchar2(200)		:=  'Modify Request for Quote';
AHC_TXT_007	constant varchar2(200)		:=  'Delete Request for Quote';
AHC_TXT_008	constant varchar2(200)		:=  'Date Last Changed';
AHC_TXT_009	constant varchar2(200)		:=  'Description of RFQ Item';
AHC_TXT_010	constant varchar2(200)		:=  'Is Item Valid';

AHC_TXT_011	constant varchar2(200)		:=  'Max Reserve Price<BR>Per Item';
AHC_TXT_012	constant varchar2(200)		:=  'RFQ Successfully Inserted';
AHC_TXT_013	constant varchar2(200)		:=  'RFQ Successfully Modified';
AHC_TXT_014	constant varchar2(200)		:=  'Standard Request for Quote';
AHC_TXT_015	constant varchar2(200)		:=  'Invalid RFQ Due Date Entered';
AHC_TXT_016	constant varchar2(200)		:=  'Price Book Copied';
AHC_TXT_017	constant varchar2(200)		:=  'A PostCode must be entered';
AHC_TXT_018	constant varchar2(200)		:=  'Undefined Item';
AHC_TXT_019	constant varchar2(200)		:=  'Request for Quote Closed';
AHC_TXT_020	constant varchar2(200)		:=  'List Request for Quotes';

AHC_TXT_021	constant varchar2(200)		:=  'Winning Quote';
AHC_TXT_022	constant varchar2(200)		:=  'No Bid';
AHC_TXT_023	constant varchar2(200)		:=  'Manufacturers Invited to Bid';
AHC_TXT_024	constant varchar2(200)		:=  'Mass Update Facility';
AHC_TXT_025	constant varchar2(200)		:=  'Manage Manufacturer Tender List';
AHC_TXT_026	constant varchar2(200)		:=  'Manufacturer Tender List Modified';
AHC_TXT_027	constant varchar2(200)		:=  'Request for Quote Notification';
AHC_TXT_029	constant varchar2(200)		:=  'Review Bid';
AHC_TXT_030	constant varchar2(200)		:=  'Manufacturer Bids for Tender';

AHC_TXT_031	constant varchar2(200)		:=  'Successful Bid';
AHC_TXT_032	constant varchar2(200)		:=  'Review all Bids for this Item';
AHC_TXT_033	constant varchar2(200)		:=  'Review Manufacturer Bids for';
AHC_TXT_034	constant varchar2(200)		:=  'Update Winning Manufacturer Bid';
AHC_TXT_035	constant varchar2(200)		:=  'Bids Updated';
AHC_TXT_036	constant varchar2(200)		:=  'Update Bid Details';
AHC_TXT_037	constant varchar2(200)		:=  'Bid Entered';
AHC_TXT_038	constant varchar2(200)		:=  'List Reverse Auctions';
AHC_TXT_039	constant varchar2(200)		:=  'Available Reverse Auctions';
AHC_TXT_040	constant varchar2(200)		:=  'Reverse Auction Product Name';

AHC_TXT_041	constant varchar2(200)		:=  'Product Location';
AHC_TXT_042	constant varchar2(200)		:=  'Reverse Auction Closed';
AHC_TXT_043	constant varchar2(200)		:=  'Reverse Auction Open';
AHC_TXT_044	constant varchar2(200)		:=  'No Reverse Auctions are Available';
AHC_TXT_045	constant varchar2(200)		:=  'Create New Reverse Auction';
AHC_TXT_046	constant varchar2(200)		:=  'Manager Reverse Auction';
AHC_TXT_047	constant varchar2(200)		:=  'Insert Reverse Auction';
AHC_TXT_048	constant varchar2(200)		:=  'Modify Reverse Auction';
AHC_TXT_049	constant varchar2(200)		:=  'Unique Product Id / Manufacturer Code';
AHC_TXT_050	constant varchar2(200)		:=  'Qty From';

AHC_TXT_051	constant varchar2(200)		:=  'Qty To';
AHC_TXT_052	constant varchar2(200)		:=  'Reverse Auction History';
AHC_TXT_053	constant varchar2(200)		:=  'Date Achieved';
AHC_TXT_054	constant varchar2(200)		:=  'Scaling Price List';
AHC_TXT_055	constant varchar2(200)		:=  'Delete Reverse Auction';
AHC_TXT_056	constant varchar2(200)		:=  'Reverse Auction Deleted';
AHC_TXT_057	constant varchar2(200)		:=  'Reverse Auction Updated';
AHC_TXT_058	constant varchar2(200)		:=  'Reverse Auction Inserted';
AHC_TXT_059	constant varchar2(200)		:=  'Reverse Auction Bid Management';
AHC_TXT_060	constant varchar2(200)		:=  'No Bid has been Entered';

AHC_TXT_061	constant varchar2(200)		:=  'Current Price per Unit';
AHC_TXT_062	constant varchar2(200)		:=  'Bid Quantity';
AHC_TXT_063	constant varchar2(200)		:=  'Update Bid';
AHC_TXT_064	constant varchar2(200)		:=  'Warning: You have reduced your Bid Qty';
AHC_TXT_065	constant varchar2(200)		:=  'Your Bid Quantity has been increased';
AHC_TXT_066	constant varchar2(200)		:=  'Invalid Qunatity Entered';
AHC_TXT_067	constant varchar2(200)		:=  'Quantity entered must be greater than 0';
AHC_TXT_068	constant varchar2(200)		:=  'Unable to Determine Price Per Unit as no pricing information available';
AHC_TXT_069	constant varchar2(200)		:=  'No Change Made to Bid Qty';
AHC_TXT_070	constant varchar2(200)		:=  'Your bid has been Deleted';

AHC_TXT_071	constant varchar2(200)		:=  'Total Charge Amount';
AHC_TXT_072	constant varchar2(200)		:=  'Current Customer Bids';
AHC_TXT_073	constant varchar2(200)		:=  'Price exceeds Reserve Price';
AHC_TXT_074	constant varchar2(200)		:=  'Quantity<BR>Required';
AHC_TXT_075	constant varchar2(200)		:=  'Item Bid Total';
AHC_TXT_076	constant varchar2(200)		:=  'Logins by Month';
AHC_TXT_077	constant varchar2(200)		:=  'Include in Some Categories';
AHC_TXT_078	constant varchar2(200)		:=  'This Price Book contains Direct Shop Items.';
AHC_TXT_079	constant varchar2(200)		:=  'Map Shop Items to Categories';
AHC_TXT_080	constant varchar2(200)		:=  'Categories';

AHC_TXT_081	constant varchar2(200)		:=  'Modify Mapping Details';
AHC_TXT_082	constant varchar2(200)		:=  'Mapping Details Successfully Modified';
AHC_TXT_083	constant varchar2(200)		:=  'Break on Months';
AHC_TXT_084	constant varchar2(200)		:=  'Statistics on PreOrders';
AHC_TXT_085	constant varchar2(200)		:=  '# PreOrders/Orders';
AHC_TXT_086	constant varchar2(200)		:=  'Number PreOrders<BR>with Address Details';
AHC_TXT_087	constant varchar2(200)		:=  'Average PreOrder';
AHC_TXT_088	constant varchar2(200)		:=  'Smallest PreOrder';
AHC_TXT_089	constant varchar2(200)		:=  'Largest PreOrder';
AHC_TXT_090	constant varchar2(200)		:=  'Preorders<BR>more than $100';

AHC_TXT_091	constant varchar2(200)		:=  'Total PreOrders';
AHC_TXT_092	constant varchar2(200)		:=  'PreOrders with Address Details';
AHC_TXT_093	constant varchar2(200)		:=  'Change Status to Ordered';
AHC_TXT_094	constant varchar2(200)		:=  'Logins by Day of Week';
AHC_TXT_095	constant varchar2(200)		:=  'Day of Week';
AHC_TXT_096	constant varchar2(200)		:=  'Display all Order Types';
AHC_TXT_097	constant varchar2(200)		:=  'Can see Price Book';
AHC_TXT_098	constant varchar2(200)		:=  'Price Book is Public';
--AHC_TXT_099	constant varchar2(200)		:=  'Image Location';
AHC_TXT_100	constant varchar2(200)		:=  'Day From';

AHC_TXT_101	constant varchar2(200)		:=  'Day To';
AHC_TXT_102	constant varchar2(200)		:=  'Purchase Order Audit Trail';
AHC_TXT_103	constant varchar2(200)		:=  'Column Modified';
AHC_TXT_104	constant varchar2(200)		:=  'New Value';
AHC_TXT_105	constant varchar2(200)		:=  'Changed By';
AHC_TXT_106	constant varchar2(200)		:=  'Administrator';
AHC_TXT_107	constant varchar2(200)		:=  'Public Price Book';
AHC_TXT_108	constant varchar2(200)		:=  'Enable all Watermarks';
AHC_TXT_109	constant varchar2(200)		:=  'RANGE FROM';
AHC_TXT_110	constant varchar2(200)		:=  'RANGE TO';

AHC_TXT_111	constant varchar2(200)		:=  'Display All';
AHC_TXT_112	constant varchar2(200)		:=  'Reports Deleted';
AHC_TXT_113	constant varchar2(200)		:=  'Customer Comment';
AHC_TXT_114	constant varchar2(200)		:=  'Extra Order Information';
AHC_TXT_115	constant varchar2(200)		:=  'Table Background Header';
AHC_TXT_116	constant varchar2(200)		:=  'Table Background Cell';
AHC_TXT_117	constant varchar2(200)		:=  'Statistics Across All Accounts';
AHC_TXT_118	constant varchar2(200)		:=  'Meta Tag Table Background';
AHC_TXT_119	constant varchar2(200)		:=  'Please enter in bug details below';
AHC_TXT_120	constant varchar2(200)		:=  'Do not Run in Batch';

AHC_TXT_121	constant varchar2(200)		:=  'Major Catastrophe - Customers cannot use the application';
AHC_TXT_122	constant varchar2(200)		:=  'Serious Problem - Customers Impacted';
AHC_TXT_123	constant varchar2(200)		:=  'Minor Problem - Inconvenient but not the end of the world';
AHC_TXT_124	constant varchar2(200)		:=  'Hiccup - Nothing serious, but should be looked at';
AHC_TXT_125	constant varchar2(200)		:=  'Priority (Please be realistic with this)';
AHC_TXT_126	constant varchar2(200)		:=  'Bug';
AHC_TXT_127	constant varchar2(200)		:=  'Feature Enhancement';
AHC_TXT_128	constant varchar2(200)		:=  'Wording does not make sense';
AHC_TXT_129	constant varchar2(200)		:=  'Screen design needs improving';
AHC_TXT_130	constant varchar2(200)		:=  'Documentation is incorrect';

AHC_TXT_131	constant varchar2(200)		:=  'Icon is not meaningful';
AHC_TXT_132	constant varchar2(200)		:=  'Other';
AHC_TXT_133	constant varchar2(200)		:=  'Type of Fix';
AHC_TXT_134	constant varchar2(200)		:=  'Where did the problem occur?';
AHC_TXT_135	constant varchar2(200)		:=  'Problem Description';
AHC_TXT_136	constant varchar2(200)		:=  'Submit Bug Report';
AHC_TXT_137	constant varchar2(200)		:=  'Piction Bug Report';
AHC_TXT_138	constant varchar2(200)		:=  'Bug Report Submitted';
AHC_TXT_139	constant varchar2(200)		:=  'This Report has been emailed to the PICTION Chief Technical Officer';
AHC_TXT_140	constant varchar2(200)		:=  'Advertisers';

AHC_TXT_141	constant varchar2(200)		:=  'Create New Advertiser';
AHC_TXT_142	constant varchar2(200)		:=  'Advert Charge Plans';
AHC_TXT_143	constant varchar2(200)		:=  'Daily';
AHC_TXT_144	constant varchar2(200)		:=  'Return to Administration';
AHC_TXT_145	constant varchar2(200)		:=  'Enter in new Advertiser Details';
AHC_TXT_146	constant varchar2(200)		:=  'Advertiser Details';
AHC_TXT_147	constant varchar2(200)		:=  'Advertiser Name';
AHC_TXT_148	constant varchar2(200)		:=  '(1) Contact Name';
AHC_TXT_149	constant varchar2(200)		:=  '(1) Contact Email';
AHC_TXT_150	constant varchar2(200)		:=  '(1) Contact Phone';

AHC_TXT_151	constant varchar2(200)		:=  '(2) Contact Name';
AHC_TXT_152	constant varchar2(200)		:=  '(2) Contact Email';
AHC_TXT_153	constant varchar2(200)		:=  '(2) Contact Phone';
AHC_TXT_154	constant varchar2(200)		:=  '(3) Contact Name';
AHC_TXT_155	constant varchar2(200)		:=  '(3) Contact Email';
AHC_TXT_156	constant varchar2(200)		:=  '(3) Contact Phone';
AHC_TXT_157	constant varchar2(200)		:=  'Contact Address';
AHC_TXT_158	constant varchar2(200)		:=  'Business Summary';
AHC_TXT_159	constant varchar2(200)		:=  'Insert New Advertiser';
AHC_TXT_160	constant varchar2(200)		:=  'Modify Advertiser';

AHC_TXT_161	constant varchar2(200)		:=  'Delete Advertiser';
AHC_TXT_162	constant varchar2(200)		:=  'Advertisement Campaigns';
AHC_TXT_163	constant varchar2(200)		:=  'Campaign Name';
AHC_TXT_164	constant varchar2(200)		:=  'Target Theme';
AHC_TXT_165	constant varchar2(200)		:=  'Create New Campaign';
AHC_TXT_166	constant varchar2(200)		:=  'Advertiser has been completely deleted';
AHC_TXT_167	constant varchar2(200)		:=  'Advertiser Successfully Modified';
AHC_TXT_168	constant varchar2(200)		:=  'Enter in new Advertiser Charge Plan Details';
AHC_TXT_169	constant varchar2(200)		:=  'Charge Plan Details';
AHC_TXT_170	constant varchar2(200)		:=  'Charge Name';

AHC_TXT_171	constant varchar2(200)		:=  'Charge Amount $';
AHC_TXT_172	constant varchar2(200)		:=  'Frequency of Adverts (1-5)';
AHC_TXT_173	constant varchar2(200)		:=  'Number of Days Plan is Valid For';
AHC_TXT_174	constant varchar2(200)		:=  'Target Business Feature';
AHC_TXT_175	constant varchar2(200)		:=  'Target Clients';
AHC_TXT_176	constant varchar2(200)		:=  'Target Couples';
AHC_TXT_177	constant varchar2(200)		:=  'Target Customers/Guests';
AHC_TXT_178	constant varchar2(200)		:=  'Real Estate - Top of Screen';
AHC_TXT_179	constant varchar2(200)		:=  'Real Estate - Choice Bar Top';
AHC_TXT_180	constant varchar2(200)		:=  'Real Estate - Choice Bar Bottom';

AHC_TXT_181	constant varchar2(200)		:=  'Real Estate - First Page';
AHC_TXT_182	constant varchar2(200)		:=  'Insert New Charge Plan';
AHC_TXT_183	constant varchar2(200)		:=  'Weekly';
AHC_TXT_184	constant varchar2(200)		:=  'Monthly';
AHC_TXT_185	constant varchar2(200)		:=  'Specify Frequency';
AHC_TXT_186	constant varchar2(200)		:=  'Charge Plan has been completely deleted';
AHC_TXT_187	constant varchar2(200)		:=  'No amount supplied';
AHC_TXT_188	constant varchar2(200)		:=  'Plan Successfully Modified';
AHC_TXT_189	constant varchar2(200)		:=  'Campaign';
AHC_TXT_190	constant varchar2(200)		:=  'Hourly use MI (35). Daily use HH24:MI (14:20).';

AHC_TXT_191	constant varchar2(200)		:=  'Charged Amount';
AHC_TXT_192	constant varchar2(200)		:=  'Frequency';
AHC_TXT_193	constant varchar2(200)		:=  'Insert New Campaign';
AHC_TXT_194	constant varchar2(200)		:=  'Modify Campaign';
AHC_TXT_195	constant varchar2(200)		:=  'Delete Campaign';
AHC_TXT_196	constant varchar2(200)		:=  'Advertisement Images';
AHC_TXT_197	constant varchar2(200)		:=  'Weekly use DAY HH24:MI (MON 08:00, TUE 19:30). Monthly use D HH24:MI (5 09:30 - 5th day of the Month)';
AHC_TXT_198	constant varchar2(200)		:=  'Image has no name';
AHC_TXT_199	constant varchar2(200)		:=  'Create New Image';
AHC_TXT_200	constant varchar2(200)		:=  'View Statistics for this Advertisement Campaign';

AHC_TXT_201	constant varchar2(200)		:=  'Campaign Statistics';
AHC_TXT_202	constant varchar2(200)		:=  'Advert Image';
AHC_TXT_203	constant varchar2(200)		:=  'Saw Advert';
AHC_TXT_204	constant varchar2(200)		:=  'Distinct Access Hits (Saw Advert)';
AHC_TXT_205	constant varchar2(200)		:=  'Clicked on Advert';
AHC_TXT_206	constant varchar2(200)		:=  'Campaign has been completely deleted';
AHC_TXT_207	constant varchar2(200)		:=  'No Plan Name';
AHC_TXT_208	constant varchar2(200)		:=  'Campaing Successfully Modified';
AHC_TXT_209	constant varchar2(200)		:=  'Enter in New Image Details';
AHC_TXT_210	constant varchar2(200)		:=  'Image does not exist';

AHC_TXT_211	constant varchar2(200)		:=  'Alt Value - Image Description';
AHC_TXT_212	constant varchar2(200)		:=  'Http Link';
AHC_TXT_213	constant varchar2(200)		:=  'Display Width';
AHC_TXT_214	constant varchar2(200)		:=  'Display Height';
AHC_TXT_215	constant varchar2(200)		:=  'Store Image in Database';
AHC_TXT_216	constant varchar2(200)		:=  'Hourly';
AHC_TXT_217	constant varchar2(200)		:=  'Image Stored Externally in /adverts/';
AHC_TXT_218	constant varchar2(200)		:=  'Physical File Name';
AHC_TXT_219	constant varchar2(200)		:=  'Insert New Image';
AHC_TXT_220	constant varchar2(200)		:=  'Search for Price Book Items that Match the following Criteria' ;

AHC_TXT_221	constant varchar2(200)		:=  'Modify Image';
AHC_TXT_222	constant varchar2(200)		:=  'Item Name Matches';
AHC_TXT_223	constant varchar2(200)		:=  'Image has been deleted';
AHC_TXT_224	constant varchar2(200)		:=  'Image Successfully Added';
AHC_TXT_225	constant varchar2(200)		:=  'Use Price Book';
AHC_TXT_226	constant varchar2(200)		:=  'Individual Pricing';
AHC_TXT_227	constant varchar2(200)		:=  'Home Page Options';
AHC_TXT_228	constant varchar2(200)		:=  'Main Title';
AHC_TXT_229	constant varchar2(200)		:=  'Product Type';
AHC_TXT_230	constant varchar2(200)		:=  'Categories and # Images';

AHC_TXT_231	constant varchar2(200)		:=  'Central Image';
AHC_TXT_232	constant varchar2(200)		:=  'Customer Account Listed';
AHC_TXT_233	constant varchar2(200)		:=  'Date of Event Listed';
AHC_TXT_234	constant varchar2(200)		:=  'Date Account Expires Listed';
AHC_TXT_235	constant varchar2(200)		:=  'Price Book Expires Listed';
AHC_TXT_236	constant varchar2(200)		:=  'Modify Options';
AHC_TXT_237	constant varchar2(200)		:=  'Home Page Options Successfully Modified';
AHC_TXT_238	constant varchar2(200)		:=  'List Audio';
AHC_TXT_239	constant varchar2(200)		:=  'Download Sale Price';
AHC_TXT_240	constant varchar2(200)		:=  'You Have';

AHC_TXT_241	constant varchar2(200)		:=  'Item(s) in your Shopping Trolley';
AHC_TXT_242	constant varchar2(200)		:=  'Download Price';
AHC_TXT_243	constant varchar2(200)		:=  'Note: Image to be Downloaded';
AHC_TXT_244	constant varchar2(200)		:=  'Image Download Fee';
AHC_TXT_245	constant varchar2(200)		:=  'Shipping and Image Download Fee';
AHC_TXT_246	constant varchar2(200)		:=  'Price List';
AHC_TXT_247	constant varchar2(200)		:=  'CD Details - Choose one to upload from';
AHC_TXT_248	constant varchar2(200)		:=  'Manufacturer Stock Clearance Orders';
AHC_TXT_249	constant varchar2(200)		:=  'Notify all Bidders by Email if they have been successful or unsuccessful';
AHC_TXT_250	constant varchar2(200)		:=  'Price Between';

AHC_TXT_251	constant varchar2(200)		:=  'Unsuccessful Bid';
AHC_TXT_252	constant varchar2(200)		:=  'Quick Create Price Book Items<BR>based on Manufacturer(s)';
AHC_TXT_253	constant varchar2(200)		:=  'Add the following Percentage to Each Item<BR><i>eg. 10 is 10%</i>';
AHC_TXT_254     constant varchar2(200)		:=  'And then Modify Resulting Price Book Items (or see what gets returned from the Query)';
AHC_TXT_255     constant varchar2(200)		:=  'Record Not Found';
AHC_TXT_256     constant varchar2(200)		:=  'Increase Price by';
AHC_TXT_257     constant varchar2(200)		:=  'Rename Price Book';
AHC_TXT_258     constant varchar2(200)		:=  'Old Price Book';
AHC_TXT_259     constant varchar2(200)		:=  'New Price Book';
AHC_TXT_260     constant varchar2(200)		:=  'Delete Price Book';

AHC_TXT_261     constant varchar2(200)		:=  'Change Product To';
AHC_TXT_262     constant varchar2(200)		:=  'Price Book name cannot be Empty';
AHC_TXT_263     constant varchar2(200)		:=  'Price Book already exists';
AHC_TXT_264     constant varchar2(200)		:=  'Change Delivery Time (Local) To';
AHC_TXT_265     constant varchar2(200)		:=  'Cannot Rename Price Book to itself';
AHC_TXT_266     constant varchar2(200)		:=  'Price Book has been renamed';
AHC_TXT_267     constant varchar2(200)		:=  'Reset a Business Feature value across all Business Features';
AHC_TXT_268     constant varchar2(200)		:=  'Check to Enable, Uncheck to Disable Business Feature Name';
AHC_TXT_269     constant varchar2(200)		:=  'Business Feature Number';
AHC_TXT_270     constant varchar2(200)		:=  'Update all Business Features';

AHC_TXT_271     constant varchar2(200)		:=  'Modification Made';
AHC_TXT_272     constant varchar2(200)		:=  'Bad Number Entered';
AHC_TXT_273     constant varchar2(200)		:=  'Before a Product can be created, a Price Book must be created first';
AHC_TXT_274     constant varchar2(200)		:=  'No Categories exist. Images cannot be loaded until Private Categories are created';
AHC_TXT_275     constant varchar2(200)		:=  'Contact Us';
AHC_TXT_276     constant varchar2(200)		:=  'Fill in the Details below';
AHC_TXT_277     constant varchar2(200)		:=  'Use this Form to send us Feedback';
AHC_TXT_278     constant varchar2(200)		:=  'Send Feedback';
AHC_TXT_279     constant varchar2(200)		:=  'You have exceeded your limit for creating accounts. Please contact your Sales Administrator to purchase more.';
AHC_TXT_280     constant varchar2(200)		:=  'Your Feedback has been Sent. Thank you.';

AHC_TXT_281     constant varchar2(200)		:=  'There was no feedback to be sent.';
AHC_TXT_282     constant varchar2(200)		:=  'Closed. Bids entered and won for all items';
AHC_TXT_283     constant varchar2(200)		:=  'Tender has been fulfilled. Please contact Tradeprice for shipping and handling.';
AHC_TXT_284     constant varchar2(200)		:=  'Change Delivery Time (Int) To';
AHC_TXT_285     constant varchar2(200)		:=  'RFQ Details';
AHC_TXT_286     constant varchar2(200)		:=  'Cancel Order';
AHC_TXT_287     constant varchar2(200)		:=  'Order has been Cancelled and Shopping Basket Emptied';
AHC_TXT_288     constant varchar2(200)		:=  'Stop Report From Running';
AHC_TXT_289     constant varchar2(200)		:=  'Image Load Statistics';
AHC_TXT_290     constant varchar2(200)		:=  'Loads done today';

AHC_TXT_291     constant varchar2(200)		:=  'Loads by Client';
AHC_TXT_292     constant varchar2(200)		:=  'Total Images Loaded';
AHC_TXT_293     constant varchar2(200)		:=  'Total Images Succesfully Loaded';
AHC_TXT_294     constant varchar2(200)		:=  'Most Popular Images Accessed';
AHC_TXT_295     constant varchar2(200)		:=  'Top 10 Most Popular Images Viewed';
AHC_TXT_296     constant varchar2(200)		:=  'Top 10 Least Popular Images Viewed';
AHC_TXT_297     constant varchar2(200)		:=  'Total Times Images has been Accessed';
AHC_TXT_298     constant varchar2(200)		:=  'Least Popular Images Accessed';
AHC_TXT_299     constant varchar2(200)		:=  'Images not yet Accessed';
AHC_TXT_300     constant varchar2(200)		:=  'Times Image has been viewed';

AHC_TXT_301     constant varchar2(200)		:=  'Change Production Time To';
AHC_TXT_302     constant varchar2(200)		:=  'Change Surcharge (Local) To';
AHC_TXT_303     constant varchar2(200)		:=  'Change Surcharge (Int) To';
AHC_TXT_304     constant varchar2(200)		:=  'Workflow Set Orders';
AHC_TXT_305     constant varchar2(200)		:=  'Display Column Listing of Categories';
AHC_TXT_306     constant varchar2(200)		:=  'Display Mfctr Clearance Details instead of Image';
AHC_TXT_307     constant varchar2(200)		:=  'Default Business Feature';
AHC_TXT_308     constant varchar2(200)		:=  'Default Look and Feel';
AHC_TXT_309     constant varchar2(200)		:=  'Download Price Book';
AHC_TXT_310     constant varchar2(200)		:=  'Price Book has been Downloaded';

AHC_TXT_311     constant varchar2(200)		:=  'Cross Reference';
AHC_TXT_312     constant varchar2(200)		:=  'Change Workflow To';
AHC_TXT_313     constant varchar2(200)		:=  'Perform Mass Update';
AHC_TXT_314     constant varchar2(200)		:=  'Report Only - No Values Modified';
AHC_TXT_315     constant varchar2(200)		:=  'Resulting Listing after all Modifications have been made';
AHC_TXT_316     constant varchar2(200)		:=  'Existing Settings';
AHC_TXT_317     constant varchar2(200)		:=  'No Records found that match the Search Criteria';
AHC_TXT_318     constant varchar2(200)		:=  'Sort by Purchase Order Id';
AHC_TXT_319     constant varchar2(200)		:=  'Allowed Zoom Factors';
AHC_TXT_320     constant varchar2(200)		:=  'Create New Order';

AHC_TXT_321     constant varchar2(200)		:=  'Client Private Icons';
AHC_TXT_322     constant varchar2(200)		:=  'Client Public Icons';
AHC_TXT_323     constant varchar2(200)		:=  'Customer Icons';
AHC_TXT_324     constant varchar2(200)		:=  'End of Update';
AHC_TXT_325     constant varchar2(200)		:=  'Description and Shape';
AHC_TXT_326     constant varchar2(200)		:=  'Matte';
AHC_TXT_327     constant varchar2(200)		:=  'Home Page';
AHC_TXT_328     constant varchar2(200)		:=  'Misc Features';
AHC_TXT_329     constant varchar2(200)		:=  'Title Bar';
AHC_TXT_330     constant varchar2(200)		:=  'Display Icons';

AHC_TXT_331     constant varchar2(200)		:=  'Display All Icons';
AHC_TXT_332     constant varchar2(200)		:=  'Standard Look';
AHC_TXT_333     constant varchar2(200)		:=  'Left Hand Frame';
AHC_TXT_334     constant varchar2(200)		:=  'Customer Top Frame';
AHC_TXT_335     constant varchar2(200)		:=  'Look and Feel Name cannot be empty';
AHC_TXT_336     constant varchar2(200)		:=  'For Order to be processed it must be minimum of';
AHC_TXT_337     constant varchar2(200)		:=  'To Download the Image, click on the File Name Link Below';
AHC_TXT_338     constant varchar2(200)		:=  'If the Image Appears, right mouse click on it, and choose SAVE PICTURE AS';
AHC_TXT_339     constant varchar2(200)		:=  'Long Scrollbar';
AHC_TXT_340     constant varchar2(200)		:=  'Send Email to all Recipients in Address Book';

AHC_TXT_341     constant varchar2(200)		:=  'Enter in Emails contents below and Press Send';
AHC_TXT_342     constant varchar2(200)		:=  'Send';
AHC_TXT_343     constant varchar2(200)		:=  'No Subject';
AHC_TXT_344     constant varchar2(200)		:=  'The following email was sent';
AHC_TXT_345     constant varchar2(200)		:=  'Quick Create of a Client';
AHC_TXT_346     constant varchar2(200)		:=  'Take copies of the following customer account';
AHC_TXT_347     constant varchar2(200)		:=  'Customer Username';
AHC_TXT_348     constant varchar2(200)		:=  'Product Documentation';
AHC_TXT_349     constant varchar2(200)		:=  'Customer<BR>Max Price';
AHC_TXT_350     constant varchar2(200)		:=  'Display Username';

AHC_TXT_351     constant varchar2(200)		:=  'Link to Another Site';
AHC_TXT_352     constant varchar2(200)		:=  'Link Name';
AHC_TXT_353     constant varchar2(200)		:=  'New Window';
AHC_TXT_354     constant varchar2(200)		:=  'HTTP Address';
AHC_TXT_355     constant varchar2(200)		:=  'Previously Run Reports';
AHC_TXT_356     constant varchar2(200)		:=  'Greeting Card Manager';
AHC_TXT_357     constant varchar2(200)		:=  'Create new Greeting Card Style';
AHC_TXT_358     constant varchar2(200)		:=  'Greeting Card Style';
AHC_TXT_359     constant varchar2(200)		:=  'Display Font';
AHC_TXT_360     constant varchar2(200)		:=  'Manage Greeting Card';

AHC_TXT_361     constant varchar2(200)		:=  'Insert New Greeting Card';
AHC_TXT_362     constant varchar2(200)		:=  'Modify Greeting Card Details';
AHC_TXT_363     constant varchar2(200)		:=  'Greeting Card Style Name';
AHC_TXT_364     constant varchar2(200)		:=  'Greeting Card Image Location';
AHC_TXT_365     constant varchar2(200)		:=  'Recalculate Image Sort Values';
AHC_TXT_366     constant varchar2(200)		:=  'Greeting Card Location cannot be empty';
AHC_TXT_367     constant varchar2(200)		:=  'This Greeting Card Name already exists';
AHC_TXT_368     constant varchar2(200)		:=  'Greeting Card Details Modified';
AHC_TXT_369     constant varchar2(200)		:=  'Delete Greeting Card';
AHC_TXT_370     constant varchar2(200)		:=  'Greeting Card has been Deleted';

AHC_TXT_371     constant varchar2(200)		:=  'Greeting Card has been Inserted';
AHC_TXT_372     constant varchar2(200)		:=  'Downloading of Images is only Available when Payment has been Received';
AHC_TXT_373     constant varchar2(200)		:=  'This Brand Already Exists';
AHC_TXT_374     constant varchar2(200)		:=  'Brand Details Successfully Modified';
AHC_TXT_375     constant varchar2(200)		:=  'Set all Images to Value (1-100)';
AHC_TXT_376     constant varchar2(200)		:=  'Set Value based on Images Viewed';
AHC_TXT_377     constant varchar2(200)		:=  'Set Value based on Images Purchased';
AHC_TXT_378     constant varchar2(200)		:=  'MULTIPLE SQL';
AHC_TXT_379     constant varchar2(200)		:=  'Add to';
AHC_TXT_380     constant varchar2(200)		:=  'Delete from';

AHC_TXT_381     constant varchar2(200)		:=  'Image Caption';
AHC_TXT_382     constant varchar2(200)		:=  'Customer Vertical Display Table Properties';
AHC_TXT_383     constant varchar2(200)		:=  'Vertical Display Caption Font Type';
AHC_TXT_384     constant varchar2(200)		:=  'Vertical Display Caption Font Colour';
AHC_TXT_385     constant varchar2(200)		:=  'Bottom of Thumbnail Screen - Page Numbering Style';
AHC_TXT_386     constant varchar2(200)		:=  'Pages';
AHC_TXT_387     constant varchar2(200)		:=  'Modify Sort Numbers';
AHC_TXT_388     constant varchar2(200)		:=  'There are too many Products to Display. Use Manufacturer Product Id or Cross Reference Code';
AHC_TXT_389     constant varchar2(200)		:=  'Thumbnail Summary Parameters';
AHC_TXT_390     constant varchar2(200)		:=  'Display Header';

AHC_TXT_391     constant varchar2(200)		:=  'Metatag Error';
AHC_TXT_392     constant varchar2(200)		:=  'Metatag';
AHC_TXT_393     constant varchar2(200)		:=  'Metatag Display Table Properties';
AHC_TXT_394     constant varchar2(200)		:=  'Display Category Group';
AHC_TXT_395     constant varchar2(200)		:=  'Manufacturer Product Search';
AHC_TXT_396     constant varchar2(200)		:=  'Detail';
AHC_TXT_397     constant varchar2(200)		:=  'Display Category Group Name';
AHC_TXT_398     constant varchar2(200)		:=  'Separate Buttons for the Customer Interface';
AHC_TXT_399     constant varchar2(200)		:=  'Customer Buttons';
AHC_TXT_400     constant varchar2(200)		:=  'SQL Statement<BR><I>select return value,display from ... or<BR>select display from ...</I>';

AHC_TXT_401     constant varchar2(200)		:=  'Stop Word';
AHC_TXT_402     constant varchar2(200)		:=  'Class of Product';
AHC_TXT_403     constant varchar2(200)		:=  'Dynamic Query<BR><I>select return value from ...';
AHC_TXT_404     constant varchar2(200)		:=  'Display in Report<BR>Output Header';
AHC_TXT_405     constant varchar2(200)		:=  'Revert';
AHC_TXT_406     constant varchar2(200)		:=  'Categories Containing Archived Reports';
AHC_TXT_407     constant varchar2(200)		:=  'Customer Name';
AHC_TXT_408     constant varchar2(200)		:=  'Image Statistics';
AHC_TXT_409     constant varchar2(200)		:=  'No Images could be found in the Category';
AHC_TXT_410     constant varchar2(200)		:=  'No Images could be found in the Lightbox';

AHC_TXT_411     constant varchar2(200)		:=  'No Images could be found in the Store';
AHC_TXT_412     constant varchar2(200)		:=  'Simple';
AHC_TXT_413     constant varchar2(200)		:=  'Meta Tag';
AHC_TXT_414     constant varchar2(200)		:=  'Object Access Allowed';
AHC_TXT_415     constant varchar2(200)		:=  'Multimedia Image';
AHC_TXT_416     constant varchar2(200)		:=  'Pages - Limit 10';
AHC_TXT_417     constant varchar2(200)		:=  'Slider';
AHC_TXT_418     constant varchar2(200)		:=  'Vault';
AHC_TXT_419     constant varchar2(200)		:=  'Previous';
AHC_TXT_420     constant varchar2(200)		:=  'First';

AHC_TXT_421     constant varchar2(200)		:=  'Display Colour';
AHC_TXT_422     constant varchar2(200)		:=  'The password for this account is the same as the copied account password';
AHC_TXT_423     constant varchar2(200)		:=  'Listing of all Usernames currently used';
AHC_TXT_424     constant varchar2(200)		:=  'Page Delimeter Character';
AHC_TXT_425     constant varchar2(200)		:=  'Use lines to break between buttons and thumbnails';
AHC_TXT_426     constant varchar2(200)		:=  'Goto Page';
AHC_TXT_427     constant varchar2(200)		:=  'External API Call';
AHC_TXT_428     constant varchar2(200)		:=  'Has access to External APIs';
AHC_TXT_429     constant varchar2(200)		:=  'Home Page Override API';
AHC_TXT_430     constant varchar2(200)		:=  'Control Bar Button Style';

AHC_TXT_431     constant varchar2(200)		:=  'Ignore contents of the'; -- lightbox
AHC_TXT_432     constant varchar2(200)		:=  'Empty'; -- lightbox
AHC_TXT_433     constant varchar2(200)		:=  'Price Book Load Results';
AHC_TXT_434     constant varchar2(200)		:=  'All Disabled Features';
AHC_TXT_435     constant varchar2(200)		:=  'View contents of the'; -- lightbox
AHC_TXT_436     constant varchar2(200)		:=  'Add Image to the'; -- lightbox
AHC_TXT_437     constant varchar2(200)		:=  'Delete Image from the'; -- lightbox
AHC_TXT_438     constant varchar2(200)		:=  'Delete Profile';
AHC_TXT_439     constant varchar2(200)		:=  'Profile has been Deleted';
AHC_TXT_440     constant varchar2(200)		:=  'I do not want my email address<BR>to be used for unsolicited email';

AHC_TXT_441     constant varchar2(200)		:=  'Forgotten your Password?';
AHC_TXT_442     constant varchar2(200)		:=  'Enter in your Username and your Password<BR>will be emailed to your current Email Address';
AHC_TXT_443     constant varchar2(200)		:=  'Does not wish<BR>to receive<BR>unsolicited email';
AHC_TXT_444     constant varchar2(200)		:=  'FTP or<BR>Remote Procedure Call';
AHC_TXT_445     constant varchar2(200)		:=  'REMOTE PROCEDURE CALL';
AHC_TXT_446     constant varchar2(200)		:=  'Email me my Password';
AHC_TXT_447     constant varchar2(200)		:=  'Email has been sent in the last 24 hours';
AHC_TXT_448     constant varchar2(200)		:=  'Your Login Details from';
AHC_TXT_449     constant varchar2(200)		:=  'Email Address not Supplied';
AHC_TXT_450     constant varchar2(200)		:=  'Current Password not found. Unable to send.';

AHC_TXT_451     constant varchar2(200)		:=  'An Email has been sent to your Account listing your Password.';
AHC_TXT_452     constant varchar2(200)		:=  'Username not found';
AHC_TXT_453     constant varchar2(200)		:=  'Album Manufacturing';
AHC_TXT_454     constant varchar2(200)		:=  'Image Framing';
AHC_TXT_455     constant varchar2(200)		:=  'Display Readme File';
AHC_TXT_456     constant varchar2(200)		:=  'Display Feedback Form';
AHC_TXT_457     constant varchar2(200)		:=  'Display Information about Contact Us';
AHC_TXT_458     constant varchar2(200)		:=  'Display Legal Statement';
AHC_TXT_459     constant varchar2(200)		:=  'Display Privacy Statement';
AHC_TXT_460     constant varchar2(200)		:=  'Edit Album';

AHC_TXT_461     constant varchar2(200)		:=  'Create New Album';
AHC_TXT_462     constant varchar2(200)		:=  'Name of Album';
AHC_TXT_463     constant varchar2(200)		:=  'Read Me';
AHC_TXT_464     constant varchar2(200)		:=  'Feedback';
AHC_TXT_465     constant varchar2(200)		:=  'Legal';
AHC_TXT_466     constant varchar2(200)		:=  'Privacy';
AHC_TXT_467     constant varchar2(200)		:=  'List Price Books';
AHC_TXT_468     constant varchar2(200)		:=  'Blueprint';
AHC_TXT_469     constant varchar2(200)		:=  'Relational';
AHC_TXT_470     constant varchar2(200)		:=  'Photo';

AHC_TXT_471     constant varchar2(200)		:=  'The following image(s) were successfully loaded';
AHC_TXT_472     constant varchar2(200)		:=  'No Images were found that were successfully loaded';
AHC_TXT_473     constant varchar2(200)		:=  'Delete all Session Specific';
AHC_TXT_474     constant varchar2(200)		:=  'Session Specific';
AHC_TXT_475     constant varchar2(200)		:=  'Merchant Provider';
AHC_TXT_476     constant varchar2(200)		:=  'Merchant Id';
AHC_TXT_477     constant varchar2(200)		:=  'Merchant URL Site';
AHC_TXT_478     constant varchar2(200)		:=  'Merchant Return URL';
AHC_TXT_479     constant varchar2(200)		:=  'Merchant Pop-Up New Window';
AHC_TXT_480     constant varchar2(200)		:=  'Credit Cards Supported';

AHC_TXT_481     constant varchar2(200)		:=  'Can See all Clients';
AHC_TXT_482     constant varchar2(200)		:=  'Limit to Clients';
AHC_TXT_483     constant varchar2(200)		:=  'Client Access';
AHC_TXT_484     constant varchar2(200)		:=  'Profile Password cannot be empty';
AHC_TXT_485     constant varchar2(200)		:=  'The Look and Feel does not exist';
AHC_TXT_486     constant varchar2(200)		:=  'The Business Feature does not exist';
AHC_TXT_487     constant varchar2(200)		:=  'The Username already exists';
AHC_TXT_488     constant varchar2(200)		:=  'Creation of Profiles is not allowed';
AHC_TXT_489     constant varchar2(200)		:=  'Administrator Login Page';
AHC_TXT_490     constant varchar2(200)		:=  'Broader Terms';

AHC_TXT_491     constant varchar2(200)		:=  'Thesaurus Term';
AHC_TXT_492     constant varchar2(200)		:=  'Narrower Terms';
AHC_TXT_493     constant varchar2(200)		:=  'Use';
AHC_TXT_494     constant varchar2(200)		:=  'Start Terms';
AHC_TXT_495     constant varchar2(200)		:=  'Term';
AHC_TXT_496     constant varchar2(200)		:=  'Term Id';
AHC_TXT_497     constant varchar2(200)		:=  'Term Type';
AHC_TXT_498     constant varchar2(200)		:=  'Preferred Term';
AHC_TXT_499     constant varchar2(200)		:=  'Non-preferred Term';

AHC_TXT_500     constant varchar2(200)		:=  'Term Notes';
AHC_TXT_501     constant varchar2(200)		:=  'Date Last Modified';
AHC_TXT_502     constant varchar2(200)		:=  'Other Terms';
AHC_TXT_503     constant varchar2(200)		:=  'Use For';
AHC_TXT_504     constant varchar2(200)		:=  'Using File';
AHC_TXT_505     constant varchar2(200)		:=  'List all Product Price Books';
AHC_TXT_506     constant varchar2(200)		:=  'Related Terms';
AHC_TXT_507     constant varchar2(200)		:=  'Historical Notes';
AHC_TXT_508     constant varchar2(200)		:=  'Note';
AHC_TXT_509     constant varchar2(200)		:=  'Search Notes';
AHC_TXT_510     constant varchar2(200)		:=  'Associated Images';

AHC_TXT_511     constant varchar2(200)		:=  'View Associated Images';
AHC_TXT_512     constant varchar2(200)		:=  'Tracking Term';
AHC_TXT_513     constant varchar2(200)		:=  'Note Contains';
AHC_TXT_514     constant varchar2(200)		:=  'Modified Since Date';
AHC_TXT_515     constant varchar2(200)		:=  'Create a New Thesaurus';
AHC_TXT_516     constant varchar2(200)		:=  'Modify Thesaurus Details';
AHC_TXT_517     constant varchar2(200)		:=  'Reverse Engineer a Thesaurus';
AHC_TXT_518     constant varchar2(200)		:=  'Thesaurus Security';
AHC_TXT_519     constant varchar2(200)		:=  'Delete a Thesaurus';
AHC_TXT_520     constant varchar2(200)		:=  'Gift Certificate Management';

AHC_TXT_521     constant varchar2(200)		:=  'Create a new Gift Certificate';
AHC_TXT_522     constant varchar2(200)		:=  'Delete Gift Certificate';
AHC_TXT_523     constant varchar2(200)		:=  'Product Class (Default GOODS)';
AHC_TXT_524     constant varchar2(200)		:=  'Brand Default NULL';
-- xxx there was a duplicate here
AHC_TXT_525     constant varchar2(200)		:=  'Date Gift Certificate Used';
-- AHC_TXT_525     constant varchar2(200)		:=  'Certificate valid only when used with this Customer Account';
AHC_TXT_526     constant varchar2(200)		:=  'Certificate valid across Customer Accounts';
AHC_TXT_527     constant varchar2(200)		:=  'Certificate Reference ID';
AHC_TXT_528     constant varchar2(200)		:=  'Email this Gift Certificate to Address';
AHC_TXT_529     constant varchar2(200)		:=  'Value of Gift Certificate';
AHC_TXT_530     constant varchar2(200)		:=  'Value Remaining';

AHC_TXT_531     constant varchar2(200)		:=  'Date Certificate Expires';
AHC_TXT_532     constant varchar2(200)		:=  'Certificate has Expired';
AHC_TXT_533     constant varchar2(200)		:=  'Gift Certificate Usage';
AHC_TXT_534     constant varchar2(200)		:=  'Certificate Internal ID';
AHC_TXT_535     constant varchar2(200)		:=  'Valid Across all Customer Accounts';
AHC_TXT_536     constant varchar2(200)		:=  'Certificate has not been used';
AHC_TXT_537     constant varchar2(200)		:=  'Modify Certificate details';
AHC_TXT_538     constant varchar2(200)		:=  'Certificate details Modified';
AHC_TXT_539     constant varchar2(200)		:=  'Certificate Created';
AHC_TXT_540     constant varchar2(200)		:=  'List Certificates';

AHC_TXT_541     constant varchar2(200)		:=  'Email with Gift Certificate sent';
AHC_TXT_542     constant varchar2(200)		:=  'Send to Name';
AHC_TXT_543     constant varchar2(200)		:=  'Send to Message';
AHC_TXT_544     constant varchar2(200)		:=  'You have been sent a Gift Certificate';
AHC_TXT_545     constant varchar2(200)		:=  'Send Gift Certificate Email';
AHC_TXT_546     constant varchar2(200)		:=  'Total Value of all Gift Certificates';
AHC_TXT_547     constant varchar2(200)		:=  'Total Value Spent so far on all Gift Certificates';
AHC_TXT_548     constant varchar2(200)		:=  'Total Value Outstanding on all Gift Certificates';
AHC_TXT_549     constant varchar2(200)		:=  'There are no Client Generated Event Invoices';
AHC_TXT_550     constant varchar2(200)		:=  'Client Generated Event Invoices';

AHC_TXT_551     constant varchar2(200)		:=  'Modify Event Invoice Details';
AHC_TXT_552     constant varchar2(200)		:=  'Number Purchased<BR>Pricing Charge<BR>Total Charge';
AHC_TXT_553     constant varchar2(200)		:=  'Invoice Sent';
AHC_TXT_554     constant varchar2(200)		:=  'Total Outstanding for all Invoices';
AHC_TXT_555     constant varchar2(200)		:=  'Invoice Details Modified';
AHC_TXT_556     constant varchar2(200)		:=  'Outstanding Client Generated Event Plan Invoices';
AHC_TXT_557     constant varchar2(200)		:=  'Purchase Additional Customer Accounts Online';
AHC_TXT_558     constant varchar2(200)		:=  'I Agree to be Invoiced for the Amount';
AHC_TXT_559     constant varchar2(200)		:=  'Product Class Details Modified';
AHC_TXT_560     constant varchar2(200)		:=  'Continue to Next Screen';

AHC_TXT_561     constant varchar2(200)		:=  'Enter in Quantity Required for Each Charge Event';
AHC_TXT_562     constant varchar2(200)		:=  'An Invoice will be sent to your Billing Address for the amount shown at the bottom of the screen';
AHC_TXT_563     constant varchar2(200)		:=  'Confirm Invoice Screen';
AHC_TXT_564     constant varchar2(200)		:=  'Go back to the Previous Screen';
AHC_TXT_565     constant varchar2(200)		:=  'Increase Requested';
AHC_TXT_566     constant varchar2(200)		:=  'No Valid Quantity Values Entered';
AHC_TXT_567     constant varchar2(200)		:=  'Return to Listing of Customer Accounts';
AHC_TXT_568     constant varchar2(200)		:=  'Increase to Purchase Additional Accounts has been made';
AHC_TXT_569     constant varchar2(200)		:=  'Account Type';
AHC_TXT_570     constant varchar2(200)		:=  'Public Event';

AHC_TXT_571     constant varchar2(200)		:=  'Private Event';
AHC_TXT_572     constant varchar2(200)		:=  'Event Customer must attach Job Prefix to Event Logon Id when Logging on';
AHC_TXT_573     constant varchar2(200)		:=  'Job Prefix is passed as a hidden variable when Logging on';
AHC_TXT_574     constant varchar2(200)		:=  'Event Password Control';
AHC_TXT_575     constant varchar2(200)		:=  'All Event Logons use same password as this Customer Account';
AHC_TXT_576     constant varchar2(200)		:=  'Password is manually set for each Event Logon Account';
AHC_TXT_577     constant varchar2(200)		:=  'Event Logons Password is same as Event Account Surname';
AHC_TXT_578     constant varchar2(200)		:=  'Event Logons Password is the Event Logon Id';
AHC_TXT_579     constant varchar2(200)		:=  'On Event Logon';
AHC_TXT_580     constant varchar2(200)		:=  'Manage Customer Event Logins';

AHC_TXT_581     constant varchar2(200)		:=  'Public and Private Events require a Job Reference Value';
AHC_TXT_582     constant varchar2(200)		:=  'Mass Attach Customer/Photo/Page Numbers by Load Id';
AHC_TXT_583     constant varchar2(200)		:=  'Minimum Customer/Photo/Page Number';
AHC_TXT_584     constant varchar2(200)		:=  'Maximum Customer/Photo/Page Number';
AHC_TXT_585     constant varchar2(200)		:=  'Max Mfctr Items in Price Book before Search is Required';
AHC_TXT_586     constant varchar2(200)		:=  'Number of Distinct Customer/Photo/Page Numbers';
AHC_TXT_587     constant varchar2(200)		:=  'Customer/Photo/Page Number';
AHC_TXT_588     constant varchar2(200)		:=  'First Name';
AHC_TXT_589     constant varchar2(200)		:=  'Surname';
AHC_TXT_590     constant varchar2(200)		:=  'Modify Customer Event Logins';

AHC_TXT_591     constant varchar2(200)		:=  'Display Customer Event Images';
AHC_TXT_592     constant varchar2(200)		:=  'No Images found to be Displayed';
AHC_TXT_593     constant varchar2(200)		:=  'Choose the Event Number from the List';
AHC_TXT_594     constant varchar2(200)		:=  'Event Number List';
AHC_TXT_595     constant varchar2(200)		:=  'Event Number Listing. Grouping of Numbers by';
AHC_TXT_596     constant varchar2(200)		:=  'Load Mapping of Customer ID to Customer Name';
AHC_TXT_597     constant varchar2(200)		:=  'Col 1 (Customer Id - Must be Number and Unique)';
AHC_TXT_598     constant varchar2(200)		:=  'Col 2 (First Name)';
AHC_TXT_599     constant varchar2(200)		:=  'Col 3 (Surname)';
AHC_TXT_600     constant varchar2(200)		:=  'Col 4 (Password) - Optional';

AHC_TXT_601     constant varchar2(200)		:=  'Col 5 (Extra Details) - Optional';
AHC_TXT_602     constant varchar2(200)		:=  'Use Default FTP Location';
AHC_TXT_603     constant varchar2(200)		:=  'Use REPORT_LOAD Directory';
AHC_TXT_604     constant varchar2(200)		:=  'Delete all Mappings before Load';
AHC_TXT_605     constant varchar2(200)		:=  'Load Mapping File';
AHC_TXT_606     constant varchar2(200)		:=  'File must have the following structure';
AHC_TXT_607     constant varchar2(200)		:=  'File must be in a comma delimited format';
AHC_TXT_608     constant varchar2(200)		:=  'The Following Information was Loaded';
AHC_TXT_609     constant varchar2(200)		:=  'Stock Level Default NULL';
AHC_TXT_610     constant varchar2(200)		:=  'Workflow Management';

AHC_TXT_611     constant varchar2(200)		:=  'Price Book Load Directory';
AHC_TXT_612     constant varchar2(200)		:=  'Workflow Set Name';
AHC_TXT_613     constant varchar2(200)		:=  'Unload Directory';
AHC_TXT_614     constant varchar2(200)		:=  'Default Priority';
AHC_TXT_615     constant varchar2(200)		:=  'Manage Workflow Set';
AHC_TXT_616     constant varchar2(200)		:=  'Create New Workflow Set';
AHC_TXT_617     constant varchar2(200)		:=  'The Customer Job Reference Number has to be Unique across the whole Database.';
AHC_TXT_618     constant varchar2(200)		:=  'Create New Workflow Task';
AHC_TXT_619     constant varchar2(200)		:=  'Default Is';
AHC_TXT_620     constant varchar2(200)		:=  'If the Query';

AHC_TXT_621     constant varchar2(200)		:=  'Workflow Task Deleted';
AHC_TXT_622     constant varchar2(200)		:=  'is True then perform the Activity';
AHC_TXT_623     constant varchar2(200)		:=  'Else if the Query';
AHC_TXT_624     constant varchar2(200)		:=  'Else perform the Activity';
AHC_TXT_625     constant varchar2(200)		:=  'Create New Workflow Query Clause';
AHC_TXT_626     constant varchar2(200)		:=  'New Query';
AHC_TXT_627     constant varchar2(200)		:=  'Credit Card Access';
AHC_TXT_628     constant varchar2(200)		:=  'Manage RFQ';
AHC_TXT_629     constant varchar2(200)		:=  'View Orders that have been made in previous sessions';
AHC_TXT_630     constant varchar2(200)		:=  'Can''t find it? Enter in your own Request to find an Image';

AHC_TXT_631     constant varchar2(200)		:=  'Previous Orders and Requests Made';
AHC_TXT_632     constant varchar2(200)		:=  'No Previous Orders or Requests could be found';
AHC_TXT_634     constant varchar2(200)		:=  'Type of Order';
AHC_TXT_635     constant varchar2(200)		:=  'Waiting for Authorisation';
AHC_TXT_636     constant varchar2(200)		:=  'Request Made';
AHC_TXT_637     constant varchar2(200)		:=  'Convert into an Order';
AHC_TXT_638     constant varchar2(200)		:=  'Workflow Set Successfully Created';
AHC_TXT_639     constant varchar2(200)		:=  'Compare with Business Feature';
AHC_TXT_640     constant varchar2(200)		:=  'Workflow Details Modified';

AHC_TXT_641     constant varchar2(200)		:=  'Profile Management Screen';
AHC_TXT_642     constant varchar2(200)		:=  'Purchase Request Authority';
AHC_TXT_643     constant varchar2(200)		:=  'No Approval Authority';
AHC_TXT_644     constant varchar2(200)		:=  'Approve any Profile in any Account';
AHC_TXT_645     constant varchar2(200)		:=  'Approve any Profile in this Account Only';
AHC_TXT_646     constant varchar2(200)		:=  'Can only Approve the following Profiles';
AHC_TXT_647     constant varchar2(200)		:=  'Authority Limit';
AHC_TXT_648     constant varchar2(200)		:=  'Authority Valid From';
AHC_TXT_649     constant varchar2(200)		:=  'Authority Valid To';
AHC_TXT_650     constant varchar2(200)		:=  'New Workflow Query Clause';

AHC_TXT_651     constant varchar2(200)		:=  'Authority Successfully Updated';
AHC_TXT_652     constant varchar2(200)		:=  'Approval Level';
AHC_TXT_653     constant varchar2(200)		:=  'Request Details';
AHC_TXT_654     constant varchar2(200)		:=  'Submit your Request';
AHC_TXT_655     constant varchar2(200)		:=  'No Text was Entered in for the Request';
AHC_TXT_656     constant varchar2(200)		:=  'A Contact Phone Number or Email Address needs to be provided';
AHC_TXT_657     constant varchar2(200)		:=  'Your Request has been Accepted';
AHC_TXT_658     constant varchar2(200)		:=  'Your Request Number is';
AHC_TXT_659     constant varchar2(200)		:=  'Modify Request Details';
AHC_TXT_660     constant varchar2(200)		:=  'In Progress';

AHC_TXT_661     constant varchar2(200)		:=  'Items that Satisfy the Request';
AHC_TXT_662     constant varchar2(200)		:=  'Price Book Item Id';
AHC_TXT_663     constant varchar2(200)		:=  'Ranking';
AHC_TXT_664     constant varchar2(200)		:=  'Email and Phone';
AHC_TXT_665     constant varchar2(200)		:=  'General Comments';
AHC_TXT_666     constant varchar2(200)		:=  'Return to Listing of Requests';
AHC_TXT_667     constant varchar2(200)		:=  'Modify Existing Workflow Query Clause';
AHC_TXT_668     constant varchar2(200)		:=  'Email Sent';
AHC_TXT_669     constant varchar2(200)		:=  'No Action Performed';
AHC_TXT_670     constant varchar2(200)		:=  'These Manufacturers should try and satisfy this request';

AHC_TXT_671     constant varchar2(200)		:=  'Respond by Date';
AHC_TXT_672     constant varchar2(200)		:=  'PreOrder - Sent to Bank';
AHC_TXT_673     constant varchar2(200)		:=  'Responses so far';
AHC_TXT_674     constant varchar2(200)		:=  'If Column';
AHC_TXT_675     constant varchar2(200)		:=  'Display Archived Requests';
AHC_TXT_676     constant varchar2(200)		:=  'Display Non-Archived Requests';
AHC_TXT_677     constant varchar2(200)		:=  'Request Details Successfully Modified';
AHC_TXT_678     constant varchar2(200)		:=  'Purchase Request has been Converted';
AHC_TXT_679     constant varchar2(200)		:=  'Order/Request has been Deleted';
AHC_TXT_680     constant varchar2(200)		:=  'Number of Gift Certificates';

AHC_TXT_681     constant varchar2(200)		:=  'Avg Number of Certificates Per Client';
AHC_TXT_682     constant varchar2(200)		:=  'Number of Used Certificates';
AHC_TXT_683     constant varchar2(200)		:=  'Number of Unused Certificates';
AHC_TXT_684     constant varchar2(200)		:=  'Number of Partially Used Certificates';
AHC_TXT_685     constant varchar2(200)		:=  'Number of Expired Certificates';
AHC_TXT_686     constant varchar2(200)		:=  'Tasks Requiring Attention';
AHC_TXT_687     constant varchar2(200)		:=  'Pay by Approval Authorisation';
AHC_TXT_688     constant varchar2(200)		:=  'Pay using a Gift Certificate';
AHC_TXT_689     constant varchar2(200)		:=  'Customer can pay using a Gift Certificate';
AHC_TXT_690     constant varchar2(200)		:=  'Customer can pay using Payment Authorisation';

AHC_TXT_691     constant varchar2(200)		:=  'Payment using a Gift Certificate';
AHC_TXT_692     constant varchar2(200)		:=  'Authorise Payment';
AHC_TXT_693     constant varchar2(200)		:=  'Remove Invalid Email Addresses';
AHC_TXT_694     constant varchar2(200)		:=  'Current Stock Level';
AHC_TXT_695     constant varchar2(200)		:=  'Apply Function';
AHC_TXT_696     constant varchar2(200)		:=  'Stock Level Audit Report';
AHC_TXT_697     constant varchar2(200)		:=  'And/Or';
AHC_TXT_698     constant varchar2(200)		:=  'Review Images that have been Manually Loaded';
AHC_TXT_699     constant varchar2(200)		:=  'Activity';
AHC_TXT_700     constant varchar2(200)		:=  'Stock Adjustment';

AHC_TXT_701     constant varchar2(200)		:=  'Cummulative Stock Total';
AHC_TXT_702     constant varchar2(200)		:=  'Your request will be approved by the following Authorised Personnel';
AHC_TXT_703     constant varchar2(200)		:=  'There are no Accounts that can Authorise this Payment';
AHC_TXT_704     constant varchar2(200)		:=  'Missing Help Files';
AHC_TXT_705     constant varchar2(200)		:=  'The following Help Topics are Missing';
AHC_TXT_706     constant varchar2(200)		:=  'Awaiting Authorisation';
AHC_TXT_707     constant varchar2(200)		:=  'You do not have the Authority to Authorise Payments';
AHC_TXT_708     constant varchar2(200)		:=  'There are no outstanding payments awaiting authorisation';
AHC_TXT_709     constant varchar2(200)		:=  'Authorise Checked Requests';
AHC_TXT_710     constant varchar2(200)		:=  'Payments have been Authorised';

AHC_TXT_711     constant varchar2(200)		:=  'View Previously Authorised Requests';
AHC_TXT_712     constant varchar2(200)		:=  'Check the box next to the Purchase Request number to Authorise it';
AHC_TXT_713     constant varchar2(200)		:=  'Previously Authorised Requests';
AHC_TXT_714     constant varchar2(200)		:=  'Certificate is not valid for this Account';
AHC_TXT_715     constant varchar2(200)		:=  'Certificate Id is not valid';
AHC_TXT_716     constant varchar2(200)		:=  'Certificate no longer valid';
AHC_TXT_717     constant varchar2(200)		:=  'There is no value left on this Certificate';
AHC_TXT_718     constant varchar2(200)		:=  'Total (After use of Gift Certficates)';
AHC_TXT_719     constant varchar2(200)		:=  'Certificate History';
AHC_TXT_720     constant varchar2(200)		:=  'Return to Ordering Screen';

AHC_TXT_721     constant varchar2(200)		:=  'Make Gift Certificate Payment';
AHC_TXT_722     constant varchar2(200)		:=  'Remaining Order Total';
AHC_TXT_723     constant varchar2(200)		:=  'Initial Order Total';
AHC_TXT_724     constant varchar2(200)		:=  'Enter in your Gift Certificate ID';
AHC_TXT_725     constant varchar2(200)		:=  'Amount to Pay';
AHC_TXT_726     constant varchar2(200)		:=  'Priority';
AHC_TXT_727     constant varchar2(200)		:=  'Museum';
AHC_TXT_728     constant varchar2(200)		:=  'Pages II - Limit 10';
AHC_TXT_729     constant varchar2(200)		:=  'Customer Registration Form Design';
AHC_TXT_730     constant varchar2(200)		:=  'Individual';

AHC_TXT_731     constant varchar2(200)		:=  'Corporate';
AHC_TXT_732     constant varchar2(200)		:=  'Corporate with Billing';
AHC_TXT_733     constant varchar2(200)		:=  'Modify Customer Registration Form Details';
AHC_TXT_734     constant varchar2(200)		:=  'Before Form is Opened';
AHC_TXT_735     constant varchar2(200)		:=  'Enable Form';
AHC_TXT_736     constant varchar2(200)		:=  'Can be accessed by Public';
AHC_TXT_737     constant varchar2(200)		:=  'Prompt what Type of Customer they are';
AHC_TXT_738     constant varchar2(200)		:=  'Individual is Default Customer';
AHC_TXT_739     constant varchar2(200)		:=  'Display Disclaimer';
AHC_TXT_740     constant varchar2(200)		:=  'When Form is Displayed';

AHC_TXT_741     constant varchar2(200)		:=  'Prompt for Traditional Username and Password';
AHC_TXT_742     constant varchar2(200)		:=  'Column Names are Centered';
AHC_TXT_743     constant varchar2(200)		:=  'On Form Submit';
AHC_TXT_744     constant varchar2(200)		:=  'If Username is not Unique give Options';
AHC_TXT_745     constant varchar2(200)		:=  'Auto Create Profile if Individual';
AHC_TXT_746     constant varchar2(200)		:=  'Auto Create Profile if Corporate';
AHC_TXT_747     constant varchar2(200)		:=  'Auto Create Profile if Corporate with Billing';
AHC_TXT_748     constant varchar2(200)		:=  'Auto Email on Creation if Individual';
AHC_TXT_749     constant varchar2(200)		:=  'Auto Email on Creation if Corporate';
AHC_TXT_750     constant varchar2(200)		:=  'Auto Email on Creation if Corporate with Billing';

AHC_TXT_751     constant varchar2(200)		:=  'Relogon as New User';
AHC_TXT_752     constant varchar2(200)		:=  'Transfer Existing Orders to New Account';
AHC_TXT_753     constant varchar2(200)		:=  'Transfer Lightbox to New Account';
AHC_TXT_754     constant varchar2(200)		:=  'Extended Options';
AHC_TXT_755     constant varchar2(200)		:=  'Display Extra Parameter for Customer to Enter in.';
AHC_TXT_756     constant varchar2(200)		:=  'Create Using Look and Feel';
AHC_TXT_757     constant varchar2(200)		:=  'Create Using Business Feature';
AHC_TXT_758     constant varchar2(200)		:=  'Call Program on Completion';
AHC_TXT_759     constant varchar2(200)		:=  'Choose Columns to Display';

AHC_TXT_760     constant varchar2(200)		:=  'Move/Copy Images';
AHC_TXT_761     constant varchar2(200)		:=  'Customer can Edit their Details after Registration is Complete';
AHC_TXT_762     constant varchar2(200)		:=  'All Purchased Items to be delivered<BR>at the same time (order cannot be split)';
AHC_TXT_763     constant varchar2(200)		:=  'Delivery Time Local (Days)';
AHC_TXT_764     constant varchar2(200)		:=  'Production Time';
AHC_TXT_765     constant varchar2(200)		:=  'If Mfctr Stock Level drops below';
AHC_TXT_766     constant varchar2(200)		:=  'Not Defined';
AHC_TXT_767     constant varchar2(200)		:=  'Item Can Still be Purchased';
AHC_TXT_768     constant varchar2(200)		:=  'Auto Increase Price<BR>if Mftcr Price Increases';
AHC_TXT_769     constant varchar2(200)		:=  'Display Price Book Item<BR>If Meta Tag Name';
AHC_TXT_770     constant varchar2(200)		:=  'Equals Value';

AHC_TXT_771     constant varchar2(200)		:=  'Surcharge Local';
AHC_TXT_772     constant varchar2(200)		:=  'Split Order';
AHC_TXT_774     constant varchar2(200)		:=  'Javascript';
AHC_TXT_775     constant varchar2(200)		:=  'Top Padding';
AHC_TXT_776     constant varchar2(200)		:=  'Left Padding';
AHC_TXT_777     constant varchar2(200)		:=  'ICRA Label';
AHC_TXT_778     constant varchar2(200)		:=  'Modify Workflow Query Clause';
AHC_TXT_779     constant varchar2(200)		:=  'Title for Parameter';
AHC_TXT_780     constant varchar2(200)		:=  'Display Border';

AHC_TXT_781     constant varchar2(200)		:=  'Continue with Registration';
AHC_TXT_782     constant varchar2(200)		:=  'Choose what type of Customer you are';
AHC_TXT_783     constant varchar2(200)		:=  'Display Interest Groups';
AHC_TXT_784     constant varchar2(200)		:=  'Shop Store Skin';
AHC_TXT_785     constant varchar2(200)		:=  'Display Table Cell Colours';
AHC_TXT_786     constant varchar2(200)		:=  'Shop Purchase';
AHC_TXT_787     constant varchar2(200)		:=  'Display Grouping Names';
AHC_TXT_788     constant varchar2(200)		:=  'Can Determine Skill Level';
AHC_TXT_789     constant varchar2(200)		:=  'Surcharge International';
AHC_TXT_790     constant varchar2(200)		:=  'Delivery Time International (Days)';

AHC_TXT_791     constant varchar2(200)		:=  'Delivery Time Description';
AHC_TXT_792     constant varchar2(200)		:=  'Production Description';
AHC_TXT_793     constant varchar2(200)		:=  'Stock Control';
AHC_TXT_794     constant varchar2(200)		:=  'Display Message';
AHC_TXT_795     constant varchar2(200)		:=  'Item Discounted Management';
AHC_TXT_796     constant varchar2(200)		:=  'Apply Discount';
AHC_TXT_797     constant varchar2(200)		:=  'Discount Item Price';
AHC_TXT_798     constant varchar2(200)		:=  'Discount Valid From';
AHC_TXT_799     constant varchar2(200)		:=  'Discount Valid To';
AHC_TXT_800     constant varchar2(200)		:=  'Item Display Control';

AHC_TXT_801     constant varchar2(200)		:=  'Modify Account Details';
AHC_TXT_802     constant varchar2(200)		:=  'Create an Account';
AHC_TXT_803     constant varchar2(200)		:=  'New Customer Registration';
AHC_TXT_804     constant varchar2(200)		:=  'Top Frame Look and Feel';
AHC_TXT_805     constant varchar2(200)		:=  'Mass Create Report';
AHC_TXT_806     constant varchar2(200)		:=  'Redisplay Product Item List';
AHC_TXT_807     constant varchar2(200)		:=  'No New Items found to add to the Price Book (Items might already be in the Price Book)';
AHC_TXT_808     constant varchar2(200)		:=  'Workflow State';
AHC_TXT_809     constant varchar2(200)		:=  'Workflow Activities';
AHC_TXT_810     constant varchar2(200)		:=  'View Active Workflow Orders';

AHC_TXT_811     constant varchar2(200)		:=  'Workflow Activity';
AHC_TXT_812     constant varchar2(200)		:=  'New Workflow Activity Name';
AHC_TXT_813     constant varchar2(200)		:=  'Workflow States';
AHC_TXT_814     constant varchar2(200)		:=  'New Workflow State Name';
AHC_TXT_815     constant varchar2(200)		:=  'Workflow Status';
AHC_TXT_816     constant varchar2(200)		:=  'Type of Workflow';
AHC_TXT_817     constant varchar2(200)		:=  'Query Meta Tag';
AHC_TXT_818     constant varchar2(200)		:=  'Goto Workflow';
AHC_TXT_819     constant varchar2(200)		:=  'Modify Workflow Details';
AHC_TXT_820     constant varchar2(200)		:=  'Return to Workflow Sets';

AHC_TXT_821     constant varchar2(200)		:=  'Create New Workflow';
AHC_TXT_822     constant varchar2(200)		:=  'Workflow Type';
AHC_TXT_823     constant varchar2(200)		:=  'Modify Workflow';
AHC_TXT_824     constant varchar2(200)		:=  'If Meta-Tag';
AHC_TXT_825     constant varchar2(200)		:=  'Manufacturer Product Item Search';
AHC_TXT_826     constant varchar2(200)		:=  'Then Perform Activity';
AHC_TXT_827     constant varchar2(200)		:=  'Goto Workflow Activity';
AHC_TXT_828     constant varchar2(200)		:=  'Insert New Workflow';
AHC_TXT_829     constant varchar2(200)		:=  'Search Terms';
AHC_TXT_830     constant varchar2(200)		:=  'Create New Workflow Activity';

AHC_TXT_831     constant varchar2(200)		:=  'Modify Workflow Activity';
AHC_TXT_832     constant varchar2(200)		:=  'Activity Type';
AHC_TXT_833     constant varchar2(200)		:=  'Activity Order';
AHC_TXT_834     constant varchar2(200)		:=  'Modify Workflow Activity Details';
AHC_TXT_835     constant varchar2(200)		:=  'Insert Workflow Activity Details';
AHC_TXT_836     constant varchar2(200)		:=  'Create New Workflow State';
AHC_TXT_837     constant varchar2(200)		:=  'Modify Workflow State';
AHC_TXT_838     constant varchar2(200)		:=  'Status Option';
AHC_TXT_839     constant varchar2(200)		:=  'Responsibility';
AHC_TXT_840     constant varchar2(200)		:=  'Modify Workflow State Details';

AHC_TXT_841     constant varchar2(200)		:=  'Insert Workflow State Details';
AHC_TXT_842     constant varchar2(200)		:=  'Workflow Task Created';
AHC_TXT_843     constant varchar2(200)		:=  'Workflow Task Modified';
AHC_TXT_844     constant varchar2(200)		:=  'Workflow Activity Modified';
AHC_TXT_845     constant varchar2(200)		:=  'Workflow Activity Created';
AHC_TXT_846     constant varchar2(200)		:=  'Use in Price Book';
AHC_TXT_847     constant varchar2(200)		:=  'Workflow State Modified';
AHC_TXT_848     constant varchar2(200)		:=  'Workflow State Created';
AHC_TXT_849     constant varchar2(200)		:=  'Pre Order';
AHC_TXT_850     constant varchar2(200)		:=  'Order Paid for';

AHC_TXT_851     constant varchar2(200)		:=  'Rerun Query';
AHC_TXT_852     constant varchar2(200)		:=  'Problems';
AHC_TXT_853     constant varchar2(200)		:=  'On Hold / Waiting';
AHC_TXT_854     constant varchar2(200)		:=  'Automatically Disable Account if Expired';
AHC_TXT_855     constant varchar2(200)		:=  'Top of Frame Control';
AHC_TXT_856     constant varchar2(200)		:=  'Note: If using three frames then ensure Row1 contains Client Title, Adverts, Scrollbar and All Icons. Business Features can then be used to disable these options';
AHC_TXT_857     constant varchar2(200)		:=  'Create Separate Price Books';
AHC_TXT_858     constant varchar2(200)		:=  'Gif Does Not Exist';
AHC_TXT_859     constant varchar2(200)		:=  'Generate help Index';
AHC_TXT_860     constant varchar2(200)		:=  'Missing Help Topics';

AHC_TXT_861     constant varchar2(200)		:=  'Look for Help Items Not Used';
AHC_TXT_862     constant varchar2(200)		:=  'Look for Duplicate Help Items';
AHC_TXT_863     constant varchar2(200)		:=  'Help Items Not Used';
AHC_TXT_864     constant varchar2(200)		:=  'Duplicate Help Items';
AHC_TXT_865     constant varchar2(200)		:=  'Index has been Generated';
AHC_TXT_866     constant varchar2(200)		:=  'End of Report';
AHC_TXT_867	constant varchar2(200)		:=  'Load Images';
AHC_TXT_868	constant varchar2(200)		:=  'Sort Images Priority (1-100)';
AHC_TXT_869	constant varchar2(200)		:=  'Return to Query Listing';
AHC_TXT_870	constant varchar2(200)		:=  'Workflow Query Modified';

AHC_TXT_871	constant varchar2(200)		:=  'Add New Manufacturers to this Price Book';
AHC_TXT_872	constant varchar2(200)		:=  'Delete Manufacturers from this Price Book';
AHC_TXT_873	constant varchar2(200)		:=  'There are no Manufacturers available to Add to the Price Book';
AHC_TXT_874	constant varchar2(200)		:=  'There are no Manufacturers that can be Deleted from the Price Book';
AHC_TXT_875	constant varchar2(200)		:=  'Manufacturers added to the Price Book';
AHC_TXT_876	constant varchar2(200)		:=  'Manufacturers delete from the Price Book';
AHC_TXT_877	constant varchar2(200)		:=  'Supplier Order Report';
AHC_TXT_878	constant varchar2(200)		:=  'Current Date';
AHC_TXT_879	constant varchar2(200)		:=  'total lines';
AHC_TXT_890	constant varchar2(200)		:=  'View by Purchase Order';

AHC_TXT_891	constant varchar2(200)		:=  'View by Status';
AHC_TXT_892	constant varchar2(200)		:=  'Workflow Orders';
AHC_TXT_893	constant varchar2(200)		:=  'Workflow Tasks';
AHC_TXT_894	constant varchar2(200)		:=  'There are no Purchase Orders Awaiting Attention';
AHC_TXT_895	constant varchar2(200)		:=  'Update Workflow';
AHC_TXT_896	constant varchar2(200)		:=  'Do Not Update Workflow at this Time';
AHC_TXT_897	constant varchar2(200)		:=  'Simple Requests';
AHC_TXT_898	constant varchar2(200)		:=  'Unknown Workflow';
AHC_TXT_899	constant varchar2(200)		:=  'Workflow Details Submitted';
AHC_TXT_900	constant varchar2(200)		:=  'Return to List of Tasks to Perform';

AHC_TXT_901	constant varchar2(200)		:=  'Mass Workflow Modify';
AHC_TXT_902	constant varchar2(200)		:=  'No Code Exists';
AHC_TXT_903	constant varchar2(200)		:=  'Question not Answered';
AHC_TXT_904	constant varchar2(200)		:=  'Simple Request Id';
AHC_TXT_905	constant varchar2(200)		:=  'Manufacturer Comments';
AHC_TXT_906	constant varchar2(200)		:=  'There are no Simple Requests Awaiting Attention';
AHC_TXT_907	constant varchar2(200)		:=  'Add Comments to the Simple Requests';
AHC_TXT_908	constant varchar2(200)		:=  'Comments attached to Simple Requests';
AHC_TXT_909     constant varchar2(200)		:=  'Mfctr Product Id';
AHC_TXT_910     constant varchar2(200)		:=  'Workflow Activity Deleted';

AHC_TXT_911     constant varchar2(200)		:=  'Workflow Set Deleted';
AHC_TXT_912     constant varchar2(200)		:=  'Download Object';
AHC_TXT_913     constant varchar2(200)		:=  'Limit Download Object';
AHC_TXT_914     constant varchar2(200)		:=  'Lease';
AHC_TXT_915     constant varchar2(200)		:=  'File Size and Type';
AHC_TXT_916     constant varchar2(200)		:=  'Allowed Number of Downloads';
AHC_TXT_917     constant varchar2(200)		:=  'Create New Download Object';
AHC_TXT_918     constant varchar2(200)		:=  'Details Modified';
AHC_TXT_919     constant varchar2(200)		:=  'Return without Modification';
AHC_TXT_920     constant varchar2(200)		:=  'Modify Object Details';

AHC_TXT_921     constant varchar2(200)		:=  'Manage Download Price Book Options';
AHC_TXT_922     constant varchar2(200)		:=  '# Days<BR>e.g. 1, 90, 12M, 1Y';
AHC_TXT_923     constant varchar2(200)		:=  'Actual Size<BR>e.g. 1000K, 10M, 1G';
AHC_TXT_924     constant varchar2(200)		:=  'Actual Limit<BR>e.g. 10, 100';
AHC_TXT_925     constant varchar2(200)		:=  'Legal Document/Warranty';
AHC_TXT_926     constant varchar2(200)		:=  'File Type<BR>e.g. TIFF, JPEG';
AHC_TXT_927     constant varchar2(200)		:=  'Append to File Name';
AHC_TXT_928     constant varchar2(200)		:=  'Timestamp';
AHC_TXT_929     constant varchar2(200)		:=  'Query';
AHC_TXT_930     constant varchar2(200)		:=  'Timestamp Mask or Query';

AHC_TXT_931     constant varchar2(200)		:=  'Home Page Style';
AHC_TXT_932     constant varchar2(200)		:=  'Configurable';
AHC_TXT_933     constant varchar2(200)		:=  'Event';
AHC_TXT_934     constant varchar2(200)		:=  'Use <PHOTOGRAPHER> Logo as Central Image';
AHC_TXT_935     constant varchar2(200)		:=  'Central Image can be Clicked On';
AHC_TXT_936     constant varchar2(200)		:=  'External Web Page';
AHC_TXT_937     constant varchar2(200)		:=  'Shopping Id';
AHC_TXT_938     constant varchar2(200)		:=  'Current Step';
AHC_TXT_939     constant varchar2(200)		:=  'Step';
AHC_TXT_940     constant varchar2(200)		:=  'Meta Tag Query';

AHC_TXT_941     constant varchar2(200)		:=  'Mark Completed';
AHC_TXT_942     constant varchar2(200)		:=  'Reassign';
AHC_TXT_943     constant varchar2(200)		:=  'Progress Workflow';
AHC_TXT_944     constant varchar2(200)		:=  'Illegal Shipping Id';
AHC_TXT_945     constant varchar2(200)		:=  'Return to Listing of Workflow Orders';
AHC_TXT_946     constant varchar2(200)		:=  'Workflow Reassigned';
AHC_TXT_947     constant varchar2(200)		:=  'Answer the Workflow Question';
AHC_TXT_948     constant varchar2(200)		:=  'Cannot Progress - Workflow has been Marked with an Error';
AHC_TXT_949     constant varchar2(200)		:=  'Cannot Progress - Workflow Completed';
AHC_TXT_950     constant varchar2(200)		:=  'Reassign Manufacturer';

AHC_TXT_951     constant varchar2(200)		:=  'Reassign Ownership to the Following Manufacturer';
AHC_TXT_952     constant varchar2(200)		:=  'Change Workflow Manufacturer';
AHC_TXT_953     constant varchar2(200)		:=  'HTML Table and Links';
AHC_TXT_954     constant varchar2(200)		:=  'Thumbnail Display';
AHC_TXT_955     constant varchar2(200)		:=  'File Locator Suffix';
AHC_TXT_956     constant varchar2(200)		:=  'To Delete the Background Images press the button below';
AHC_TXT_957     constant varchar2(200)		:=  'Order has either been Confirmed or Cancelled. Cannot Change';
AHC_TXT_958     constant varchar2(200)		:=  'Else perform the Activity';
AHC_TXT_959     constant varchar2(200)		:=  'Save this Else Component First';
AHC_TXT_960     constant varchar2(200)		:=  'Hypertext Links are Underlined';

AHC_TXT_961     constant varchar2(200)		:=  'Active links use small fonts size';
AHC_TXT_962     constant varchar2(200)		:=  'Shape';
AHC_TXT_963     constant varchar2(200)		:=  'Co-ordinates';
AHC_TXT_964     constant varchar2(200)		:=  'Search Type';
AHC_TXT_965     constant varchar2(200)		:=  'Simple Search';
AHC_TXT_966     constant varchar2(200)		:=  'API Call';
AHC_TXT_967     constant varchar2(200)		:=  'Manage Image Mapping';
AHC_TXT_968     constant varchar2(200)		:=  'Modify Image Mapping Details';
AHC_TXT_969     constant varchar2(200)		:=  'Calendar options';
AHC_TXT_970     constant varchar2(200)		:=  'Underline Colour';

AHC_TXT_971     constant varchar2(200)		:=  'Font Adjustment';
AHC_TXT_972     constant varchar2(200)		:=  'Background Image is used on Home Page';
AHC_TXT_973     constant varchar2(200)		:=  'Customer Account Name Prefix Reserved for any new Accounts';
AHC_TXT_974     constant varchar2(200)		:=  'Simulate Three Frame Mode';
AHC_TXT_975     constant varchar2(200)		:=  'This Username uses a Prefix already reserved. Please Choose another Username';
AHC_TXT_976     constant varchar2(200)		:=  'This Prefix clashes with an existing one.';
AHC_TXT_977     constant varchar2(200)		:=  'Base this Account on the Existing Account';
AHC_TXT_978     constant varchar2(200)		:=  'Number of Purchase Requests';
AHC_TXT_979     constant varchar2(200)		:=  'Workflow Modification Cancelled';
AHC_TXT_980     constant varchar2(200)		:=  'Post Unload Query to Run';

AHC_TXT_981     constant varchar2(200)		:=  'Pre Unload SELECT statement to Run (one column only)';
AHC_TXT_982     constant varchar2(200)		:=  'Pre Unload Key Name (embed in all statements using &lt;Key Name&gt;)';
AHC_TXT_983     constant varchar2(200)		:=  'Project Code';
AHC_TXT_984     constant varchar2(200)		:=  'Tax Code';
AHC_TXT_985     constant varchar2(200)		:=  'Fund Center';
AHC_TXT_986     constant varchar2(200)		:=  'GPO Box';
AHC_TXT_987     constant varchar2(200)		:=  'Current Key Name Value';
AHC_TXT_988     constant varchar2(200)		:=  'API Call to Display Top Frame (Top Part of Screen). Replaces all other top display.';
AHC_TXT_989     constant varchar2(200)		:=  'Auto Create Profile if Government';
AHC_TXT_990     constant varchar2(200)		:=  'Auto Create Profile if Internal';

AHC_TXT_991     constant varchar2(200)		:=  'Auto Email on Creation if Government';
AHC_TXT_992     constant varchar2(200)		:=  'Auto Email on Creation if Internal';
AHC_TXT_993     constant varchar2(200)		:=  'Types of Users that can be created';
AHC_TXT_994     constant varchar2(200)		:=  'Government';
AHC_TXT_995     constant varchar2(200)		:=  'Internal';
AHC_TXT_996     constant varchar2(200)		:=  'Notify me by Email when there are<BR>any new Images that Match this Query';
AHC_TXT_997     constant varchar2(200)		:=  'Email New';
AHC_TXT_998     constant varchar2(200)		:=  '# Rows Returned on Last Run';
AHC_TXT_999     constant varchar2(200)		:=  'Notification of New Images';

end lng4;

/
