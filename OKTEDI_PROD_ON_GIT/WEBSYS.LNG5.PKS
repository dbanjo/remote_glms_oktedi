CREATE OR REPLACE package WEBSYS.lng5
as

--
-- English Language Module #5
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

EXT_TXT_001    constant varchar2(200)     :=  'Connections by Hour of Day';
EXT_TXT_002    constant varchar2(200)     :=  'Sort by Rows Returned';
EXT_TXT_003    constant varchar2(200)     :=  'Sort by Rows Returned Descending';
EXT_TXT_004    constant varchar2(200)     :=  'Sort by Date';
EXT_TXT_005    constant varchar2(200)     :=  'Sort by Date Descending';
EXT_TXT_006    constant varchar2(200)     :=  'Query Name';
EXT_TXT_007    constant varchar2(200)     :=  'Date Query Ran';
EXT_TXT_008    constant varchar2(200)     :=  'Continue Workflow Set';
EXT_TXT_009    constant varchar2(200)     :=  'Thumbnail Skin External API Name';
EXT_TXT_010    constant varchar2(200)     :=  'Shop External Skin API Name';

EXT_TXT_011    constant varchar2(200)     :=  'Restrict Login to IP Addresses that Match';
EXT_TXT_012    constant varchar2(200)     :=  'Account access restricted to fixed IP Address value';
EXT_TXT_013    constant varchar2(200)     :=  'All Customers Accounts Restricted to the following IP Address (wildcards allowed)';
EXT_TXT_014    constant varchar2(200)     :=  'On Login';
EXT_TXT_015    constant varchar2(200)     :=  'On Login Page Options Successfully Modified';
EXT_TXT_016    constant varchar2(200)     :=  'Guest: Prompt for Home Country';
EXT_TXT_017    constant varchar2(200)     :=  'Customer: Prompt for Home Country if not in Contact Details';
EXT_TXT_018    constant varchar2(200)     :=  'Guest: Display Disclaimer Page';
EXT_TXT_019    constant varchar2(200)     :=  'Customer: Display Disclaimer Page';
EXT_TXT_020    constant varchar2(200)     :=  'Guest: Prompt for Email';

EXT_TXT_021    constant varchar2(200)     :=  'Customer: Prompt for Email if not in Contact Details';
EXT_TXT_022    constant varchar2(200)     :=  'Bottom Frame Replacement API';
EXT_TXT_023    constant varchar2(200)     :=  'API Calls';
EXT_TXT_024    constant varchar2(200)     :=  'Exclusive Purchase. Lockout for Time Period';
EXT_TXT_025    constant varchar2(200)     :=  'Minutes';
EXT_TXT_026    constant varchar2(200)     :=  'Local Lockout Period.';
EXT_TXT_027    constant varchar2(200)     :=  'International Lockout Period.';
EXT_TXT_028    constant varchar2(200)     :=  'Royalty Distribution';
EXT_TXT_029    constant varchar2(200)     :=  'Royalty Receiver';
EXT_TXT_030    constant varchar2(200)     :=  'Percentage Assigned';

EXT_TXT_031    constant varchar2(200)     :=  'Royalty Distribution';
EXT_TXT_032    constant varchar2(200)     :=  'Royalty Received';
EXT_TXT_033    constant varchar2(200)     :=  'Lock Out Report';
EXT_TXT_034    constant varchar2(200)     :=  'Underline Active';
EXT_TXT_035    constant varchar2(200)     :=  'Underline Visited';
EXT_TXT_036    constant varchar2(300)     :=  'Images can be moved from a Sub-Category to another within the same overall Category. To do this, choose the overall highlighted category, and on the following page remap all the sub-categories into their new ones.';
EXT_TXT_037    constant varchar2(200)     :=  'Full Image';
EXT_TXT_038    constant varchar2(200)	  :=  'Full Image Text Font';
EXT_TXT_039    constant varchar2(200)     :=  'Full Image Text Colour';
EXT_TXT_040    constant varchar2(200)	  :=  'Full Image Background Colour';

EXT_TXT_041    constant varchar2(200)	  :=  'Full Image Javascript Pop Window';
EXT_TXT_042    constant varchar2(200)	  :=  'Full Image Type of Display';
EXT_TXT_043    constant varchar2(200)	  :=  'Popup Window Width';
EXT_TXT_044    constant varchar2(200)	  :=  'Popup Window height';
EXT_TXT_045    constant varchar2(200)     :=  'Age';
EXT_TXT_046    constant varchar2(200)     :=  'Weeks';
EXT_TXT_047    constant varchar2(200)     :=  'Since Last Login';
EXT_TXT_048    constant varchar2(200)     :=  'Set Value based on Image Id (Changes Orderby and not Sort Value)';
EXT_TXT_049    constant varchar2(200)     :=  'Disable All';
EXT_TXT_050    constant varchar2(200)     :=  'What''s New';

EXT_TXT_051    constant varchar2(200)     :=  'Manage All the';
EXT_TXT_052    constant varchar2(200)     :=  'New Image';
EXT_TXT_053    constant varchar2(200)     :=  'Home Page News';
EXT_TXT_054    constant varchar2(200)     :=  'News Titles';
EXT_TXT_055    constant varchar2(200)     :=  'Create New News Item';
EXT_TXT_056    constant varchar2(200)     :=  'Column to Display Text';
EXT_TXT_057    constant varchar2(200)     :=  'No Title';
EXT_TXT_058    constant varchar2(200)     :=  'Insert New News Item';
EXT_TXT_059    constant varchar2(200)     :=  'Update News Item';
EXT_TXT_060    constant varchar2(200)     :=  'Delete News Item';

EXT_TXT_061    constant varchar2(200)     :=  'Return to Home Page Options';
EXT_TXT_062    constant varchar2(200)     :=  'Home Page News Item Inserted';
EXT_TXT_063    constant varchar2(200)     :=  'Home Page News Item Modified';
EXT_TXT_064    constant varchar2(200)     :=  'Title Highlight Colour';
EXT_TXT_065    constant varchar2(200)     :=  'Title Font Colour';
EXT_TXT_066    constant varchar2(200)     :=  'Title Adjust Font by';
EXT_TXT_067    constant varchar2(200)     :=  'Column';
EXT_TXT_068    constant varchar2(200)     :=  'News Text Font';
EXT_TXT_069    constant varchar2(200)     :=  'News Text Font Colour';
EXT_TXT_070    constant varchar2(200)     :=  'News Text Adjust Font by';

EXT_TXT_071    constant varchar2(200)     :=  'News Text';
EXT_TXT_072    constant varchar2(200)     :=  'News Reference Link';
EXT_TXT_073    constant varchar2(200)     :=  'Link/Search Term/API Call';
EXT_TXT_074    constant varchar2(200)     :=  'If Search - Categories';
EXT_TXT_075    constant varchar2(200)     :=  'If Search - Age';
EXT_TXT_076    constant varchar2(200)     :=  'Display Thumbnail and/or Text as Reference Link';
EXT_TXT_077    constant varchar2(200)     :=  'Reference Link Display Text';
EXT_TXT_078    constant varchar2(200)     :=  'Show Line After News Item';
EXT_TXT_079    constant varchar2(200)     :=  'Display To';
EXT_TXT_080    constant varchar2(200)     :=  'Show';

EXT_TXT_081    constant varchar2(200)     :=  'Do Not Show';
EXT_TXT_082    constant varchar2(200)     :=  'Customer and Guest';
EXT_TXT_083    constant varchar2(200)     :=  'Manage Help';
EXT_TXT_084    constant varchar2(200)     :=  'Job';
EXT_TXT_085    constant varchar2(200)     :=  'IP Address';
EXT_TXT_086    constant varchar2(200)     :=  'Monitor Illegal Access Attempts';
EXT_TXT_087    constant varchar2(200)     :=  'Create New';
EXT_TXT_088    constant varchar2(200)     :=  'with this name already exists';
EXT_TXT_089    constant varchar2(200)     :=  'name cannot be empty';
EXT_TXT_090    constant varchar2(200)     :=  'Name of';

EXT_TXT_091    constant varchar2(200)     :=  '# Image<BR>with Notes';
EXT_TXT_092    constant varchar2(200)     :=  'Manage';
EXT_TXT_093    constant varchar2(200)     :=  'Attach Note';
EXT_TXT_094    constant varchar2(200)     :=  'Assign to Manufacturer';
EXT_TXT_095    constant varchar2(200)     :=  'Add/Replace Note';
EXT_TXT_096    constant varchar2(200)     :=  'Add/Replace Note and Return';
EXT_TXT_097    constant varchar2(200)     :=  'Move to';
EXT_TXT_098    constant varchar2(200)     :=  'Estimated Due Date';
EXT_TXT_099    constant varchar2(200)     :=  'Manage Table and Column Comments';
EXT_TXT_100    constant varchar2(200)     :=  'Table and Column Comments';

EXT_TXT_101    constant varchar2(200)     :=  'Tables and Columns without Comments';
EXT_TXT_102    constant varchar2(200)     :=  'Generate Comment File';
EXT_TXT_103    constant varchar2(200)     :=  'Load Comment File';
EXT_TXT_104    constant varchar2(200)     :=  'Delete all Comments';
EXT_TXT_105    constant varchar2(200)     :=  'All Comments Deleted';
EXT_TXT_106    constant varchar2(200)     :=  'Comment File Generated to';
EXT_TXT_107    constant varchar2(200)     :=  'Comments Loaded';
EXT_TXT_108    constant varchar2(200)     :=  'Tables and Columns with Comments';
EXT_TXT_109    constant varchar2(200)     :=  'Add all Images on the Screen to the';
EXT_TXT_110    constant varchar2(200)     :=  'CBO Statistics';

EXT_TXT_111    constant varchar2(200)     :=  'Objects with Statistics';
EXT_TXT_112    constant varchar2(200)     :=  'Objects without Statistics';
EXT_TXT_113    constant varchar2(200)     :=  'Tables with Chained Rows';
EXT_TXT_114    constant varchar2(200)     :=  'Tables not in the CBO Table';
EXT_TXT_115    constant varchar2(200)     :=  'Mass Edit Meta Data';
EXT_TXT_116    constant varchar2(200)     :=  'Manage Batch Queue';
EXT_TXT_117    constant varchar2(200)     :=  'Check to Delete';
EXT_TXT_118    constant varchar2(200)     :=  'Job Id';
EXT_TXT_119    constant varchar2(200)     :=  'Time to Run';
EXT_TXT_120    constant varchar2(200)     :=  'What';

EXT_TXT_121    constant varchar2(200)     :=  'Modify Job Queue';
EXT_TXT_122    constant varchar2(200)     :=  'Debug Mode Enabled';
EXT_TXT_123    constant varchar2(200)     :=  'Toggle Skin';
EXT_TXT_124    constant varchar2(200)     :=  'Toggle Skin API Call';
EXT_TXT_125    constant varchar2(200)     :=  'Priority of the Shopping Basket Item';
EXT_TXT_126    constant varchar2(200)     :=  'Initialise';
EXT_TXT_127    constant varchar2(200)     :=  'Initialise with Workflow Activity';
EXT_TXT_128    constant varchar2(200)     :=  'Product Description shown to Customer';
EXT_TXT_129    constant varchar2(200)     :=  'Product Description Default Null';
EXT_TXT_130    constant varchar2(200)     :=  'Include Subdirectories';

EXT_TXT_131    constant varchar2(200)     :=  'Track Access';
EXT_TXT_132    constant varchar2(200)     :=  'Check Shopping Basket';
EXT_TXT_133    constant varchar2(200)     :=  'Access Statistics';
EXT_TXT_134    constant varchar2(200)     :=  'Manage Order Styles';
EXT_TXT_135    constant varchar2(200)     :=  'Purchase Request Display';
EXT_TXT_136    constant varchar2(200)	  :=  'Order Title Bar Page Text Font';
EXT_TXT_137    constant varchar2(200)	  :=  'Order Title Bar Font Colour';
EXT_TXT_138    constant varchar2(200)	  :=  'Order Title Bar Colour';
EXT_TXT_139    constant varchar2(200)	  :=  'Order Standard Text Font';
EXT_TXT_140    constant varchar2(200)	  :=  'Order Standard Text Colour';

EXT_TXT_141    constant varchar2(200)	  :=  'Order Standard Background Colour';
EXT_TXT_142    constant varchar2(200)	  :=  'Order Table Background Header';
EXT_TXT_143    constant varchar2(200)	  :=  'Order Table Background Cell';
EXT_TXT_144    constant varchar2(200)	  :=  'Order Standard Increase Font by';
EXT_TXT_145    constant varchar2(200)	  :=  'Order Style';
EXT_TXT_146    constant varchar2(200)	  :=  'Underline Anchors/Links';
EXT_TXT_147    constant varchar2(200)	  :=  'For the Ordering to work, an Order Style must be attached to the Account';
EXT_TXT_148    constant varchar2(200)	  :=  'Outside Columns HTML Table Width';
EXT_TXT_149    constant varchar2(200)	  :=  'Guest Account Ordering Style';
EXT_TXT_150    constant varchar2(200)	  :=  'Optional: Ordering Style for the Guest Account. If blank, uses the style listed above';

EXT_TXT_151    constant varchar2(200)	  :=  'Internal HTML Tables Width';
EXT_TXT_152    constant varchar2(200)	  :=  'Thumbnail Bottom of Screen API';
EXT_TXT_153    constant varchar2(200)	  :=  'Order Show Shopping Cart API';
EXT_TXT_154    constant varchar2(200)	  :=  'Order Show Receipt API';
EXT_TXT_155    constant varchar2(200)	  :=  'Manage Project Codes';
EXT_TXT_156    constant varchar2(200)	  :=  'Modify Project Codes';
EXT_TXT_157    constant varchar2(200)	  :=  'Date Released';
EXT_TXT_158    constant varchar2(200)	  :=  'Local';
EXT_TXT_159    constant varchar2(200)	  :=  'International';
EXT_TXT_160    constant varchar2(200)	  :=  'Customers/Profiles can Edit this Meta Tag (if priv given them)';

EXT_TXT_161    constant varchar2(200)	  :=  'Help on the Meta Tag';
EXT_TXT_162    constant varchar2(200)	  :=  'SQL Query Update Mask';
EXT_TXT_163    constant varchar2(200)	  :=  'Is Allowed to Update Meta Tag Values';
EXT_TXT_164    constant varchar2(200)	  :=  'Payment Receipt';
EXT_TXT_165    constant varchar2(200)	  :=  'Reduce the Web Quality of an Image';
EXT_TXT_166    constant varchar2(200)	  :=  'Reduce the Thumbnail Pixel Width';
EXT_TXT_167    constant varchar2(200)	  :=  'Reduce the Thumbnail Pixel Height';
EXT_TXT_168    constant varchar2(200)	  :=  'Rename the Images back to their Original Name';
EXT_TXT_169    constant varchar2(200)	  :=  'Update Meta Data Values';
EXT_TXT_170    constant varchar2(200)	  :=  'Modify Sort Numbers attached to an Image';

EXT_TXT_171    constant varchar2(200)	  :=  'Do Not Modify Meta Data, just see the rows that would be Modified';
EXT_TXT_172    constant varchar2(200)	  :=  'Change Categories based on Load Id';
EXT_TXT_173    constant varchar2(200)	  :=  'Change Roll Name based on Load Id';
EXT_TXT_174    constant varchar2(200)	  :=  'Change Film Size based on Load Id';
EXT_TXT_175    constant varchar2(200)	  :=  'Change Type of Product based on Load Id';
EXT_TXT_176    constant varchar2(200)	  :=  'Change FTP Location based on Load Id';
EXT_TXT_177    constant varchar2(200)	  :=  'Change to Value';
EXT_TXT_178    constant varchar2(200)	  :=  'Where Category is';
EXT_TXT_179    constant varchar2(200)	  :=  'and/or Image Name Like';
EXT_TXT_180    constant varchar2(200)	  :=  'Cashier';

EXT_TXT_181    constant varchar2(200)	  :=  'Enter in the Purchase Request Numbers and the Cheque Receipt Numbers';
EXT_TXT_182    constant varchar2(200)	  :=  'Cheque Receipt Number';
EXT_TXT_183    constant varchar2(200)	  :=  'Manage Cheques';
EXT_TXT_184    constant varchar2(200)	  :=  'Insert New Cheques Received';
EXT_TXT_185    constant varchar2(200)	  :=  'Confirm Cheque Receipt Numbers and Purchase Request Numbers';
EXT_TXT_186    constant varchar2(200)	  :=  'Confirm';
EXT_TXT_187    constant varchar2(200)	  :=  'Amount Due';
EXT_TXT_188    constant varchar2(200)	  :=  'Invalid Purchase Request Number';
EXT_TXT_189    constant varchar2(200)	  :=  'Return to Previous Screen and Start Again';
EXT_TXT_190    constant varchar2(200)	  :=  'Purchase Receipt and Cheque Values Confirmed';

EXT_TXT_191    constant varchar2(200)	  :=  'Enter in More Purchase Request Details';
EXT_TXT_192    constant varchar2(200)	  :=  'No Description Provided.';
EXT_TXT_193    constant varchar2(200)	  :=  'Cull Email Log';
EXT_TXT_194    constant varchar2(200)	  :=  'Email Log';
EXT_TXT_195    constant varchar2(200)	  :=  'Is SMS (T/F)';
EXT_TXT_196    constant varchar2(200)	  :=  'At Step';
EXT_TXT_197    constant varchar2(200)	  :=  'Manage Countries and Currencies';
EXT_TXT_198    constant varchar2(200)	  :=  'Modify Currency/Country Details';
EXT_TXT_199    constant varchar2(200)	  :=  'Currency/Country Details Modified';
EXT_TXT_200    constant varchar2(200)	  :=  'Main Image Display API';

EXT_TXT_201    constant varchar2(200)	  :=  'Thumbnail Skin';
EXT_TXT_202    constant varchar2(200)	  :=  'Simple Vertical';
EXT_TXT_203    constant varchar2(200)	  :=  'Slider Display Style';
EXT_TXT_204    constant varchar2(200)	  :=  'Screen Style';
EXT_TXT_205    constant varchar2(200)	  :=  'Main Image';
EXT_TXT_206    constant varchar2(200)	  :=  'Thumbnails';
EXT_TXT_207    constant varchar2(200)	  :=  'Find';
EXT_TXT_208    constant varchar2(200)	  :=  'Include Simple Search at base of Screen';
EXT_TXT_209    constant varchar2(200)	  :=  'Include Disclaimer/Privacy Bar at base of Screen';
EXT_TXT_210    constant varchar2(200)	  :=  'Slider Search Style';

EXT_TXT_211     constant varchar2(200)	  :=  'Pages III - Limit 10';
EXT_TXT_212     constant varchar2(200)	  :=  'General Border around Thumbnails and all Data';
EXT_TXT_213     constant varchar2(200)	  :=  'General Border. Colour';
EXT_TXT_214     constant varchar2(200)	  :=  'General Border. Frame Pixel Width';
EXT_TXT_215     constant varchar2(200)	  :=  'General Border. Pixel Distance Gap Around Thumbnail';
EXT_TXT_216     constant varchar2(200)	  :=  'Simple Search Display Style';
EXT_TXT_217     constant varchar2(200)	  :=  'Display Ignore Lightbox Checkbox';
EXT_TXT_218     constant varchar2(200)	  :=  'Style when displaying Previous Queries';
EXT_TXT_219     constant varchar2(200)	  :=  'Elegant';
EXT_TXT_220     constant varchar2(200)	  :=  'Default Search';

EXT_TXT_221     constant varchar2(200)	  :=  'Never went further than Disclaimer/Details Page';
EXT_TXT_222     constant varchar2(200)	  :=  'Extract Photo No from Image Name';
EXT_TXT_223     constant varchar2(200)	  :=  'Manufacturer/Shop Search Display Style';
EXT_TXT_224     constant varchar2(200)	  :=  'Title to be used for Describing Manufacturer Search';
EXT_TXT_225     constant varchar2(200)	  :=  'LHF Bottom Screen API';
EXT_TXT_226     constant varchar2(200)	  :=  'Search for Image Number (+1, -1, either side)';
EXT_TXT_227     constant varchar2(200)	  :=  'Lock Look and Feel from being Modified';
EXT_TXT_228     constant varchar2(200)	  :=  'This Look and Feel has been locked and cannot be Modified';
EXT_TXT_229     constant varchar2(200)	  :=  'Embed Object';
EXT_TXT_230     constant varchar2(200)	  :=  'Position of Thumbnail';

EXT_TXT_231     constant varchar2(200)	  :=  'On Line Poll';
EXT_TXT_232     constant varchar2(200)	  :=  'Right';
EXT_TXT_233     constant varchar2(200)	  :=  'Bottom';
EXT_TXT_234     constant varchar2(200)	  :=  'Both';
EXT_TXT_235     constant varchar2(200)	  :=  'Meta Data Screens';
EXT_TXT_236     constant varchar2(200)	  :=  'Meta Data Screen Creation';
EXT_TXT_237     constant varchar2(200)	  :=  'Make Default';
EXT_TXT_238     constant varchar2(200)	  :=  'Email to';
EXT_TXT_239     constant varchar2(200)	  :=  'Calendar';
EXT_TXT_240     constant varchar2(200)	  :=  'Calculator';

EXT_TXT_241     constant varchar2(200)	  :=  'Enable Top of Frame Control Buttons';
EXT_TXT_242     constant varchar2(200)	  :=  'Enable Bottom of Frame Control Buttons';
EXT_TXT_243     constant varchar2(200)	  :=  'Images in Shopping Basket';
EXT_TXT_244     constant varchar2(200)	  :=  'Images in';
EXT_TXT_245     constant varchar2(200)	  :=  'Email Images';
EXT_TXT_246     constant varchar2(200)	  :=  'Return to Lightbox Management';
EXT_TXT_247     constant varchar2(200)	  :=  'Send Email';
EXT_TXT_248     constant varchar2(200)	  :=  'contents emailed to';
EXT_TXT_249     constant varchar2(200)	  :=  'Order Style Name';
EXT_TXT_250     constant varchar2(200)	  :=  'Date Last Updated';

EXT_TXT_251     constant varchar2(200)	  :=  'Order Styles';
EXT_TXT_252     constant varchar2(200)	  :=  'Type of Style';
EXT_TXT_253     constant varchar2(200)	  :=  'Typical';
EXT_TXT_254     constant varchar2(200)	  :=  'Offer All Options';
EXT_TXT_255     constant varchar2(200)	  :=  'Bare Minimum Options';
EXT_TXT_256     constant varchar2(200)	  :=  'Images are Free';
EXT_TXT_257     constant varchar2(200)	  :=  'Order Display Name cannot be Empty';
EXT_TXT_258     constant varchar2(200)	  :=  'Order Style with this Name Already Exists';
EXT_TXT_259     constant varchar2(200)	  :=  'Payment Methods';
EXT_TXT_260     constant varchar2(200)	  :=  'Price/Discounts';

EXT_TXT_261     constant varchar2(200)	  :=  'Screen Control';
EXT_TXT_262     constant varchar2(200)	  :=  'Text to Display';
EXT_TXT_263     constant varchar2(200)	  :=  'Help to Display';
EXT_TXT_264     constant varchar2(200)	  :=  'Workflow';
EXT_TXT_265     constant varchar2(200)	  :=  'Accounts Mapped to this Order Style';
EXT_TXT_266     constant varchar2(200)	  :=  'Alternate Order Style';
EXT_TXT_267     constant varchar2(200)	  :=  'B2C Enabled';
EXT_TXT_268     constant varchar2(200)	  :=  'Accounts Mapped to this Order Style on Expiry';
EXT_TXT_269     constant varchar2(200)	  :=  'Initial Order Style';
EXT_TXT_270     constant varchar2(200)	  :=  'Residing Country';

EXT_TXT_271     constant varchar2(200)	  :=  'Currency to use for Orders';
EXT_TXT_272     constant varchar2(200)	  :=  'Order Tracking Display Style';
EXT_TXT_273     constant varchar2(200)	  :=  'Tracing Style API';
EXT_TXT_274     constant varchar2(200)	  :=  'Is this the Default Order Style?';
EXT_TXT_275     constant varchar2(200)	  :=  'Merchant Facilities (Credit Card)';
EXT_TXT_276     constant varchar2(200)	  :=  'Cheque/Money Order';
EXT_TXT_277     constant varchar2(200)	  :=  'Monthly Billing';
EXT_TXT_278     constant varchar2(200)	  :=  'Authorisation';
EXT_TXT_279     constant varchar2(200)	  :=  'Gift Certificate';
EXT_TXT_280     constant varchar2(200)	  :=  'If Order Problems Use';

EXT_TXT_281     constant varchar2(200)	  :=  'Display Gif Next to Payment Option';
EXT_TXT_282     constant varchar2(200)	  :=  'Non Credit Card Orders can be Cancelled';
EXT_TXT_283     constant varchar2(200)	  :=  'For Order Styles marked as the Photo Laboratory handling it.<BR>If enabled, Lab handles payment of all orders.<BR>If disabled, then the Lab handles Credit Card only';
EXT_TXT_284     constant varchar2(200)	  :=  'Discounts and Charges';
EXT_TXT_285     constant varchar2(200)	  :=  'Customer Discount';
EXT_TXT_286     constant varchar2(200)	  :=  'Only Apply Discount if Order Total is Greater Than';
EXT_TXT_287     constant varchar2(200)	  :=  'Apply this Discount in the Calculation at';
EXT_TXT_288     constant varchar2(200)	  :=  'Sub Total + Postage + Gift Wrap + (Surcharge)';
EXT_TXT_289     constant varchar2(200)	  :=  'Sub Total + Postage + Gift Wrap + (Surcharge) + Tax';
EXT_TXT_290     constant varchar2(200)	  :=  'Gift Wrap Charge';

EXT_TXT_291     constant varchar2(200)	  :=  'Postage';
EXT_TXT_292     constant varchar2(200)	  :=  'Shipping Local';
EXT_TXT_293     constant varchar2(200)	  :=  'Postage is Included in Price of Item';
EXT_TXT_294     constant varchar2(200)	  :=  'Shipping International';
EXT_TXT_295     constant varchar2(200)	  :=  'Express Post Local';
EXT_TXT_296     constant varchar2(200)	  :=  'Express Postage is Offered';
EXT_TXT_297     constant varchar2(200)	  :=  'Express Post International';
EXT_TXT_298     constant varchar2(200)	  :=  'If the Sub Total is Zero, then there is no Postage Charge';
EXT_TXT_299     constant varchar2(200)	  :=  'Customer can have their Order Split';
EXT_TXT_300     constant varchar2(200)	  :=  'Title to be used for Describing Postage';

EXT_TXT_301     constant varchar2(200)	  :=  'Novelty Set';
EXT_TXT_302     constant varchar2(200)	  :=  'Novelty Set Management';
EXT_TXT_303     constant varchar2(200)	  :=  'Postal Zone';
EXT_TXT_304     constant varchar2(200)	  :=  'Country Reference';
EXT_TXT_305     constant varchar2(200)	  :=  'Currency';
EXT_TXT_306     constant varchar2(200)	  :=  'Novelty Set Name';
EXT_TXT_307     constant varchar2(200)	  :=  'Novelty Definition';
EXT_TXT_308     constant varchar2(200)	  :=  'Modify Novelty Definitions';
EXT_TXT_309     constant varchar2(200)	  :=  'Novelty Set Details Modified';
EXT_TXT_310    constant varchar2(200)	  :=  'SQL Query Insert Mask';

EXT_TXT_311    constant varchar2(200)	  :=  'SQL Query Delete Mask';
EXT_TXT_312    constant varchar2(200)	  :=  'Two Display Values, Comma Separated';
EXT_TXT_313    constant varchar2(200)	  :=  'External Query';
EXT_TXT_314    constant varchar2(200)	  :=  'Remote SQL Query';
EXT_TXT_315    constant varchar2(200)	  :=  'After Simple/Advanced Search Value Entered API Call';
EXT_TXT_316    constant varchar2(200)	  :=  'Search Sort on'; -- Image Name: CST_TXT_132 Image Id: PHG_TXT_048 Sort Image Priority:  AHC_TXT_868 Age: EXT_TXT_045
EXT_TXT_317    constant varchar2(200)	  :=  'Replace Search API Call';
EXT_TXT_318    constant varchar2(200)	  :=  'Search Call uses Oracle Intermedia Text<BR>(Documents Only and they must be indexed using Document Match Novelty)';
EXT_TXT_319    constant varchar2(200)	  :=  'Specialised Reports and Utilities';
EXT_TXT_320    constant varchar2(200)	  :=  'Client - Customer Monthly Summary';

EXT_TXT_321    constant varchar2(200)	  :=  'Reached the Status: Order Completed, in the Month';
EXT_TXT_322    constant varchar2(200)	  :=  'by Month Completed';
EXT_TXT_323    constant varchar2(200)	  :=  'View Workflow Tasks';
EXT_TXT_324    constant varchar2(200)	  :=  'Workflow Attribute';
EXT_TXT_325    constant varchar2(200)	  :=  'General Edit';
EXT_TXT_326    constant varchar2(200)	  :=  'Post Image Load';
EXT_TXT_327    constant varchar2(200)	  :=  'Image Load';
EXT_TXT_328    constant varchar2(200)	  :=  'Meta Screen Type';
EXT_TXT_329    constant varchar2(200)	  :=  'Create New Meta Screen';
EXT_TXT_330    constant varchar2(200)	  :=  'Existing Meta Screens';

EXT_TXT_331    constant varchar2(200)	  :=  'User Defined';
EXT_TXT_332    constant varchar2(200)	  :=  'Group - Similarly Displayed Attributes';
EXT_TXT_333    constant varchar2(200)	  :=  'Group Title (same name - same row)';
EXT_TXT_334    constant varchar2(200)	  :=  'Table Attributes';
EXT_TXT_335    constant varchar2(200)	  :=  'Table Data Attributes';
EXT_TXT_336    constant varchar2(200)	  :=  'Modify Meta Screen Changes';
EXT_TXT_337    constant varchar2(200)	  :=  'Example Dummy Screen';
EXT_TXT_338    constant varchar2(200)	  :=  'is True then go to the Screen';
EXT_TXT_339    constant varchar2(200)	  :=  'Else go to the Screen';
EXT_TXT_340    constant varchar2(200)	  :=  'Query Details Modified';

EXT_TXT_341    constant varchar2(200)	  :=  'Modify Query Details';
EXT_TXT_342    constant varchar2(200)	  :=  'Finished';
EXT_TXT_343    constant varchar2(200)	  :=  'Client/Photographer Receives';
EXT_TXT_344    constant varchar2(200)	  :=  'Manufacturer/Lab Receives';
EXT_TXT_345    constant varchar2(200)	  :=  'Administration Receives';
EXT_TXT_346    constant varchar2(200)	  :=  'Press to Authorise Order';
EXT_TXT_347    constant varchar2(200)	  :=  'Previous Image';
EXT_TXT_348    constant varchar2(200)	  :=  'First Image';
EXT_TXT_349    constant varchar2(200)	  :=  'Next Image';
EXT_TXT_350    constant varchar2(200)	  :=  'Vertical/Detail Display Style';

EXT_TXT_351    constant varchar2(200)	  :=  'Horizontal/Summary Display Style';
EXT_TXT_352    constant varchar2(200)	  :=  'Column 1';
EXT_TXT_353    constant varchar2(200)	  :=  'Column 2';
EXT_TXT_354    constant varchar2(200)	  :=  'Title to be used for Describing Surcharge (if used)';
EXT_TXT_355    constant varchar2(200)	  :=  'Min and Max Amounts';
EXT_TXT_356    constant varchar2(200)	  :=  'Min Amount before Order is Processed';
EXT_TXT_357    constant varchar2(200)	  :=  'Max Amount Order can reach';
EXT_TXT_358    constant varchar2(200)	  :=  'Max Quantity Allowed per Item Purchased';
EXT_TXT_359    constant varchar2(200)	  :=  'Text to Display when Min or Max is Reached';
EXT_TXT_360    constant varchar2(200)	  :=  'GST Rate';

EXT_TXT_361    constant varchar2(200)	  :=  'Title to be used for Displaying GST';
EXT_TXT_362    constant varchar2(200)	  :=  'International Sales Attract GST';
EXT_TXT_363    constant varchar2(200)	  :=  'Download Available only when Status is Payment Received (eg. Credit Card) or Order Authorised';
EXT_TXT_364    constant varchar2(200)	  :=  'Can Download Original at any Time';
EXT_TXT_365    constant varchar2(200)	  :=  'Can Download Web Quality at any Time';
EXT_TXT_366    constant varchar2(200)	  :=  'Can Download Original on Purchase';
EXT_TXT_367    constant varchar2(200)	  :=  'On Download Prompt for Details (if they do not already exist)';
EXT_TXT_368    constant varchar2(200)	  :=  'Can Download Web Quality on Purchase';
EXT_TXT_369    constant varchar2(200)	  :=  'Auto Email Web Quality on Purchase';
EXT_TXT_370    constant varchar2(200)	  :=  'Display Order Summary';

EXT_TXT_371    constant varchar2(200)	  :=  'Number of Thumbnails Modified';
EXT_TXT_372    constant varchar2(200)	  :=  'Listing of Modified Thumbnails';
EXT_TXT_373    constant varchar2(200)	  :=  'Separate Table for Each Group';
EXT_TXT_374    constant varchar2(200)	  :=  'Display Border Around Whole Table';
EXT_TXT_375    constant varchar2(200)	  :=  'Attach Web Quality Photo to this Image';
EXT_TXT_376    constant varchar2(200)	  :=  'Perform this Option';
EXT_TXT_377    constant varchar2(200)	  :=  'Not Found';
EXT_TXT_378    constant varchar2(200)	  :=  'No Action';
EXT_TXT_379    constant varchar2(200)	  :=  'Option Already Performed';
EXT_TXT_380    constant varchar2(200)	  :=  'No Match Exists';

EXT_TXT_381    constant varchar2(200)	  :=  'Wording to describe a Photographer/Client';
EXT_TXT_382    constant varchar2(200)	  :=  'Discount';
EXT_TXT_383    constant varchar2(200)	  :=  'Refund';
EXT_TXT_384    constant varchar2(200)	  :=  'Admin Receives';
EXT_TXT_385    constant varchar2(200)	  :=  'Handling Fee';
EXT_TXT_386    constant varchar2(200)	  :=  '<PHOTOGRAPHER> Receives';
EXT_TXT_387    constant varchar2(200)	  :=  'Mfctr Receives';
EXT_TXT_388    constant varchar2(200)	  :=  'Royalty';
EXT_TXT_389    constant varchar2(200)	  :=  'Mfctr Product Sub Total';
EXT_TXT_390    constant varchar2(200)	  :=  'Tax on Commission';

EXT_TXT_391    constant varchar2(200)	  :=  'Mfctr Shipping';
EXT_TXT_392    constant varchar2(200)	  :=  'Surcharge';
EXT_TXT_393    constant varchar2(200)	  :=  'Novelties Customer can Access';
EXT_TXT_394    constant varchar2(200)	  :=  'Can Access all Novelties';
EXT_TXT_395    constant varchar2(200)	  :=  'Can only Access these Novelties';
EXT_TXT_396    constant varchar2(200)	  :=  'Modify Novelty Access';
EXT_TXT_397    constant varchar2(200)	  :=  'Novelty Access successfully Modified';
EXT_TXT_398    constant varchar2(200)	  :=  'On Order Page Include Simple Search';
EXT_TXT_399    constant varchar2(200)	  :=  'On Order page Include Privacy/Disclaimer Bar';
EXT_TXT_400    constant varchar2(200)	  :=  'Order Page Bottom of Screen API Call';

EXT_TXT_401    constant varchar2(200)	  :=  'In Basket, alternate/toggle colours';
EXT_TXT_402    constant varchar2(200)	  :=  'In Basket, extra column API Call';
EXT_TXT_403    constant varchar2(200)	  :=  'Alternate Toggle Colour';
EXT_TXT_404    constant varchar2(200)	  :=  'Display Novelties';
EXT_TXT_405    constant varchar2(200)	  :=  'On Login Text';
EXT_TXT_406    constant varchar2(200)	  :=  'Screen Display';
EXT_TXT_407    constant varchar2(200)	  :=  'No Display';
EXT_TXT_408    constant varchar2(200)	  :=  'GST Is Inclusive in the Price';
EXT_TXT_409    constant varchar2(200)	  :=  'Text to Describe Postage Cost';
EXT_TXT_410    constant varchar2(200)	  :=  'Text to Describe Express Cost';

EXT_TXT_411    constant varchar2(200)	  :=  'Display Order Tracking';
EXT_TXT_412    constant varchar2(200)	  :=  'Display Gift Wrap';
EXT_TXT_413    constant varchar2(200)	  :=  'Always Create';
EXT_TXT_414    constant varchar2(200)	  :=  'Order Tracking Page';
EXT_TXT_415    constant varchar2(200)	  :=  'Expires at';
EXT_TXT_416    constant varchar2(200)	  :=  'No Expiry';
EXT_TXT_417    constant varchar2(200)	  :=  'Expire in Days Time';
EXT_TXT_418    constant varchar2(200)	  :=  'Expire when Order Status is';
EXT_TXT_419    constant varchar2(200)	  :=  'Expires in Days';
EXT_TXT_420    constant varchar2(200)	  :=  'or when Status is';

EXT_TXT_421    constant varchar2(200)	  :=  'Display Customer Contact Details';
EXT_TXT_422    constant varchar2(200)	  :=  'Display Shipping';
EXT_TXT_423    constant varchar2(200)	  :=  'Display Postage';
EXT_TXT_424    constant varchar2(200)	  :=  'Display Payment Method Options';
EXT_TXT_425    constant varchar2(200)	  :=  'Display Final Order Details';
EXT_TXT_426    constant varchar2(200)	  :=  'Heading Text for Display Order Summary';
EXT_TXT_427    constant varchar2(200)	  :=  'Heading Text for Display Gift Wrap';
EXT_TXT_428    constant varchar2(200)	  :=  'Heading Text for Display Order Tracking';
EXT_TXT_429    constant varchar2(200)	  :=  'Heading Text for Display Customer Contact Details';
EXT_TXT_430    constant varchar2(200)	  :=  'Heading Text for Display Shipping';

EXT_TXT_431    constant varchar2(200)	  :=  'Use Default Price if not located in Price Book';
EXT_TXT_432    constant varchar2(200)	  :=  'Heading Text for Display Postage';
EXT_TXT_433    constant varchar2(200)	  :=  'Heading Text for Display Payment Method Options';
EXT_TXT_434    constant varchar2(200)	  :=  'Heading Text for Display Final Order Details';
EXT_TXT_435    constant varchar2(200)	  :=  'Title for Shopping Basket Listing Page';
EXT_TXT_436    constant varchar2(200)	  :=  'Title for Customer Details Page';
EXT_TXT_437    constant varchar2(200)	  :=  'Title for Payment Method Page';
EXT_TXT_438    constant varchar2(200)	  :=  'Title for Order Confirmation Page';
EXT_TXT_439    constant varchar2(200)	  :=  'Title for Receipt Page';
EXT_TXT_440    constant varchar2(200)	  :=  'Display Most Recent Images';

EXT_TXT_441    constant varchar2(200)	  :=  'Number to Display';
EXT_TXT_442    constant varchar2(200)	  :=  'Display Images with Matte';
EXT_TXT_443    constant varchar2(200)	  :=  'Display Above Thumbnail Listing';
EXT_TXT_444    constant varchar2(200)	  :=  'Display Most Popular Purchased Images';
EXT_TXT_445    constant varchar2(200)	  :=  'On Purchase of an Image go straight to the Shopping Basket';
EXT_TXT_446    constant varchar2(200)	  :=  'If all details are entered go straight to the Payment Method Page';
EXT_TXT_447    constant varchar2(200)	  :=  'Use Images instead of Buttons to Navigate Screens';
EXT_TXT_448    constant varchar2(200)	  :=  'In Three Frame, Ordering Replaces Bottom Frame';
EXT_TXT_449    constant varchar2(200)	  :=  'Place a Border around the whole display';
EXT_TXT_450    constant varchar2(200)	  :=  'Display Currency next to Total';

EXT_TXT_451    constant varchar2(200)	  :=  'Display Currency Conversion Chart';
EXT_TXT_452    constant varchar2(200)	  :=  'Use Directory Name as Category Name<BR>(Create as Private if it does not exist)';
EXT_TXT_453    constant varchar2(200)	  :=  'Do not display screen info before skin displays';
EXT_TXT_454    constant varchar2(200)	  :=  'Contact Details API Call';
EXT_TXT_455    constant varchar2(200)	  :=  'Select All';
EXT_TXT_456    constant varchar2(200)	  :=  'Deselect All';
EXT_TXT_457    constant varchar2(200)	  :=  'Details Modified';
EXT_TXT_458    constant varchar2(200)	  :=  'Details Copied';
EXT_TXT_459    constant varchar2(200)	  :=  'Goto';
EXT_TXT_460    constant varchar2(200)	  :=  'Copy To';

EXT_TXT_461    constant varchar2(200)	  :=  'Display all Payment Method Options as Buttons';
EXT_TXT_462    constant varchar2(200)	  :=  'Display Purchase Request Number in all Headings';
EXT_TXT_463    constant varchar2(200)	  :=  'Confirm then Pay (if unchecked, Pay then Confirm)';
EXT_TXT_464    constant varchar2(200)	  :=  'Location of Cheque Confirm Button on Screen';
EXT_TXT_465    constant varchar2(200)	  :=  'Display Address Details using Enhanced Method';
EXT_TXT_466    constant varchar2(200)	  :=  'Return to Shopping Basket Text';
EXT_TXT_467    constant varchar2(200)	  :=  'Proceed to Payment Method Text';
EXT_TXT_468    constant varchar2(200)	  :=  'Remove from Shopping Basket Text';
EXT_TXT_469    constant varchar2(200)	  :=  'Confirm Button';
EXT_TXT_470    constant varchar2(200)	  :=  'Message under Order Total';

EXT_TXT_471    constant varchar2(200)	  :=  'Confirm Cheque Payment';
EXT_TXT_472    constant varchar2(200)	  :=  'Top and Bottom';
EXT_TXT_473    constant varchar2(200)	  :=  'Text for Purchase Request';
EXT_TXT_474    constant varchar2(200)	  :=  'Update Contact Details to match Purchase Details when Updated';
EXT_TXT_475    constant varchar2(200)	  :=  'HTML Table Width Command for Single Column Display';
EXT_TXT_476    constant varchar2(200)	  :=  'HTML Table Width Command for Two Column Display';
EXT_TXT_477    constant varchar2(200)	  :=  'Return to Full Image Display';
EXT_TXT_478    constant varchar2(200)	  :=  'Save and Return to Full Image Display';
EXT_TXT_479    constant varchar2(200)	  :=  'Check on Creating Output File';
EXT_TXT_480    constant varchar2(200)	  :=  'Do Not Check';

EXT_TXT_481    constant varchar2(200)	  :=  'Do Not Run if File Exists';
EXT_TXT_482    constant varchar2(200)	  :=  'Make backup of Output File';
EXT_TXT_483    constant varchar2(200)	  :=  'Buttons then Text';
EXT_TXT_484    constant varchar2(200)	  :=  'Text then Buttons';
EXT_TXT_485    constant varchar2(200)	  :=  'Payment Facilities Display Style';
EXT_TXT_486    constant varchar2(200)	  :=  'International Sales Must Use Credit Card';
EXT_TXT_487    constant varchar2(200)	  :=  'Display Break between Credit Card and next Option';
EXT_TXT_488    constant varchar2(200)	  :=  'When displaying price list, sort display by';
EXT_TXT_489    constant varchar2(200)	  :=  'Display a Customer Receipt';
EXT_TXT_490    constant varchar2(200)	  :=  'Display a Customer Receipt Print Button';

EXT_TXT_491    constant varchar2(200)	  :=  'On Successful Purchase, Email Customer Order Details';
EXT_TXT_492    constant varchar2(200)	  :=  'On Successful Purchase, Email Photographer Order Details';
EXT_TXT_493    constant varchar2(200)	  :=  'For Public Accessed Accounts, Auto Create Profile on Purchase';
EXT_TXT_494    constant varchar2(200)	  :=  'On Creation, Email Address is the Username';
EXT_TXT_495    constant varchar2(200)	  :=  'Public Accounts are prompted to create their own between Steps 1 and 2.';
EXT_TXT_496    constant varchar2(200)	  :=  'Text to Appear on Checkout Button';
EXT_TXT_497    constant varchar2(200)	  :=  'Text to Appear on Recalculate Button';
EXT_TXT_498    constant varchar2(200)	  :=  'Text to Appear on Empty Basket/Cancel Button';
EXT_TXT_499    constant varchar2(200)	  :=  'Text to Appear on Logoff Button';
EXT_TXT_500    constant varchar2(200)	  :=  'Display for Shopping Basket';

EXT_TXT_501    constant varchar2(200)	  :=  'Display Thumbnails on Receipt Page';
EXT_TXT_502    constant varchar2(200)	  :=  'Display for Sub Total';
EXT_TXT_503    constant varchar2(200)	  :=  'Display for Grand Total';
EXT_TXT_504    constant varchar2(200)	  :=  'Title to be used to refer to Thumbnail in the Order Listing Header';
EXT_TXT_505    constant varchar2(200)	  :=  'Title to be used to refer to Images or Photos in the Order Listing Header';
EXT_TXT_506    constant varchar2(200)	  :=  'Title to be used to refer to Quantity in the Order Listing Header';
EXT_TXT_507    constant varchar2(200)	  :=  'Title to be used to refer to Sub Total in the Order Listing Header';
EXT_TXT_508    constant varchar2(200)	  :=  'Displayed Help on Screen for Shopping';
EXT_TXT_509    constant varchar2(200)	  :=  'Text to be displayed on Merchant Transaction Button';
EXT_TXT_510    constant varchar2(200)	  :=  'Title to be displayed when there are no Items left in the Shopping Basket';

EXT_TXT_511    constant varchar2(200)	  :=  'Text to Display on Completion of Phone Order';
EXT_TXT_512    constant varchar2(200)	  :=  'Text to Display to tell the user to print the Cheque';
EXT_TXT_513    constant varchar2(200)	  :=  'Text to Indicate Relogin on Completed Order';
EXT_TXT_514    constant varchar2(200)	  :=  'Title Text for Most Popular Images';
EXT_TXT_515    constant varchar2(200)	  :=  'Title Text for People who Purchased this Image also Purchased';
EXT_TXT_516    constant varchar2(200)	  :=  'Header Prompt for On Login';
EXT_TXT_517    constant varchar2(200)	  :=  'On Login Unsolicited Email Prompt';
EXT_TXT_518    constant varchar2(200)	  :=  'Text on Accept Button';
EXT_TXT_519    constant varchar2(200)	  :=  'Text on Decline Button';
EXT_TXT_520    constant varchar2(200)	  :=  'Text to Display in Disclaimer Box';

EXT_TXT_521    constant varchar2(200)	  :=  'Privacy Statement';
EXT_TXT_522    constant varchar2(200)	  :=  'Delayed Pricing';
EXT_TXT_523    constant varchar2(200)	  :=  'Alternative Price Book';
EXT_TXT_524    constant varchar2(200)	  :=  'Purchase Order Warning';
EXT_TXT_525    constant varchar2(200)	  :=  'Shopping Help';
EXT_TXT_526    constant varchar2(200)	  :=  'Help Purchasing';
EXT_TXT_527    constant varchar2(200)	  :=  'On Logout, Items Left in Basket';
EXT_TXT_528    constant varchar2(200)	  :=  'Start Workflow at Step';
EXT_TXT_529    constant varchar2(200)	  :=  'Step Manufacturer can see Order';
EXT_TXT_530    constant varchar2(200)	  :=  'Delivery Time Calculated at Step' ;

EXT_TXT_531    constant varchar2(200)	  :=  'Display Window without buttons before entering Merchant Site.' ;
EXT_TXT_532    constant varchar2(200)	  :=  'Order Summary Header Colour';
-- EXT_TXT_533    constant varchar2(200)	  :=  'Payment Method HTML Table Command';
EXT_TXT_534    constant varchar2(200)	  :=  'Payment Method Line Divider HTML Command';
EXT_TXT_535    constant varchar2(200)	  :=  'Cost Summary HTML Table Command';
EXT_TXT_536    constant varchar2(200)	  :=  'Cost Summary Right Hand Column HTML Table Cell Command';
EXT_TXT_537    constant varchar2(200)	  :=  'Cost Summary Left Hand Column HTML Table Cell Command';
EXT_TXT_538    constant varchar2(200)	  :=  'Postage and Delivery HTML Table Command';
EXT_TXT_539    constant varchar2(200)	  :=  'Postage and Delivery Right Hand Column HTML Table Cell Command';
EXT_TXT_540    constant varchar2(200)	  :=  'Postage and Delivery Left Hand Column HTML Table Cell Command';

EXT_TXT_541    constant varchar2(200)	  :=  'Payment Method HTML Table Command';
EXT_TXT_542    constant varchar2(200)	  :=  'Payment Method Text Column HTML Table Cell Command';
EXT_TXT_543    constant varchar2(200)	  :=  'Payment Method Left Hand Column HTML Table Cell Command';
EXT_TXT_544    constant varchar2(200)	  :=  'Customer Details HTML Table Command';
EXT_TXT_545    constant varchar2(200)	  :=  'Customer Details Right Hand Column HTML Table Cell Command';
EXT_TXT_546    constant varchar2(200)	  :=  'Customer Details Left Hand Column HTML Table Cell Command';
EXT_TXT_547    constant varchar2(200)	  :=  'Advanced Purchase Order Reporting';
EXT_TXT_548    constant varchar2(200)	  :=  'Search for Profile to Connect As';
EXT_TXT_549    constant varchar2(200)	  :=  'Connect as a Profile';
EXT_TXT_550    constant varchar2(200)	  :=  'Return to Search Screen';

EXT_TXT_551    constant varchar2(200)	  :=  'Click on the Name of the Profile to Connect as that Profile';
EXT_TXT_552    constant varchar2(200)	  :=  'Text for Return Message on Payment Screen';
EXT_TXT_553    constant varchar2(200)	  :=  'Payment Method Button Column HTML Table Cell Command';
EXT_TXT_554    constant varchar2(200)	  :=  'Is not allowed to Authorise own Payments';
EXT_TXT_555    constant varchar2(200)	  :=  'Can Authorise own Payments (payments not automatically progressed)';
EXT_TXT_556    constant varchar2(200)	  :=  'Can Authorise own Payments (payments automatically progressed)';
EXT_TXT_557    constant varchar2(200)	  :=  'Instruction Border Colour';
EXT_TXT_558    constant varchar2(200)	  :=  'Load Reconcilliation Data';
EXT_TXT_559    constant varchar2(200)	  :=  'Specify the Name of the CSV file to be loaded into the Database';
EXT_TXT_560    constant varchar2(200)	  :=  'Reconcile Data comes from';

EXT_TXT_561    constant varchar2(200)	  :=  'Or Specify CSV File Name in REPORT_LOAD Directory';
EXT_TXT_562    constant varchar2(200)	  :=  'Load Reconcilliation Data';
EXT_TXT_563    constant varchar2(200)	  :=  'Advanced Reporting Module';
EXT_TXT_564    constant varchar2(200)	  :=  'File Not Found';
EXT_TXT_565    constant varchar2(200)	  :=  'Missing Indexes';
EXT_TXT_566    constant varchar2(200)	  :=  'Table';
EXT_TXT_567    constant varchar2(200)	  :=  'Index';
EXT_TXT_568    constant varchar2(200)	  :=  'Create Prefilled Purchase Request';
EXT_TXT_569    constant varchar2(200)	  :=  'For all Items Checked, Create a Prefilled Purchase Order for the Customer. Email them to the customer to Logon and Fulfil the Request.';
EXT_TXT_570    constant varchar2(200)	  :=  'PreOrder has been created, and will be attached to the Customer, when next they login.';

EXT_TXT_571    constant varchar2(200)	  :=  'Bulk Purchase Pricing';
EXT_TXT_572    constant varchar2(200)	  :=  'None Available';
EXT_TXT_573    constant varchar2(200)	  :=  'New Charge Plan Event';
EXT_TXT_574    constant varchar2(200)	  :=  'Text for Home - Return to Search on Basket Display';
EXT_TXT_575    constant varchar2(200)	  :=  'Text for Home - On all Order Pages except for first page';
EXT_TXT_576    constant varchar2(200)	  :=  'Manufacturer Title';
EXT_TXT_577    constant varchar2(200)	  :=  'Bold Mandatory Columns';
EXT_TXT_578    constant varchar2(200)	  :=  'Italicize Mandatory Columns';
EXT_TXT_579    constant varchar2(200)	  :=  'Mark with an Asterisk Mandatory Columns';
EXT_TXT_580    constant varchar2(200)	  :=  'Perform Smart Check on Data Entered for Name, Street, Phone, Post Code and Email.';

EXT_TXT_581    constant varchar2(200)	  :=  'Merchant Facilities (Credit Card)';
EXT_TXT_582    constant varchar2(200)	  :=  'Booking System';
EXT_TXT_583    constant varchar2(200)	  :=  'Education';
EXT_TXT_584    constant varchar2(200)	  :=  'Identify Differences with Style';
EXT_TXT_585    constant varchar2(200)	  :=  'Recreate Using Existing Style';
EXT_TXT_586    constant varchar2(200)	  :=  'Recreate Using Pre-Defined Style';
EXT_TXT_587    constant varchar2(200)	  :=  'Delete (type in DELETE to Confirm Deletion)';
EXT_TXT_588    constant varchar2(200)	  :=  'Run Utility';
EXT_TXT_589    constant varchar2(200)	  :=  'Modify Order Style';
EXT_TXT_590    constant varchar2(200)	  :=  'Delivery Address';

EXT_TXT_591    constant varchar2(200)	  :=  'Invoice Address';
EXT_TXT_592    constant varchar2(200)	  :=  'Contact Information';
EXT_TXT_593    constant varchar2(200)	  :=  'already exists.';
EXT_TXT_594    constant varchar2(200)	  :=  'Request for Purchase to be Authorised';
EXT_TXT_595    constant varchar2(200)	  :=  'Could Not Reconnect back to the Server. Please contact the Photographer';
EXT_TXT_596    constant varchar2(200)	  :=  'Access to Download Denied.';
EXT_TXT_597    constant varchar2(200)	  :=  'Privacy Policy';
EXT_TXT_598    constant varchar2(200)	  :=  'To Review the Progress of Your Order';
EXT_TXT_599    constant varchar2(200)	  :=  'Use the Following URL';
EXT_TXT_600    constant varchar2(200)	  :=  'Your Order Tracking Account is';

EXT_TXT_601    constant varchar2(200)	  :=  'Your Order Tracking Password is';
EXT_TXT_602    constant varchar2(200)	  :=  'An Account has Automatically been Created for you';
EXT_TXT_603    constant varchar2(200)	  :=  'When you next login, use the following Details';
EXT_TXT_604    constant varchar2(200)	  :=  'Account Username';
EXT_TXT_605    constant varchar2(200)	  :=  'Account Password';
EXT_TXT_606    constant varchar2(200)	  :=  'Request Authorised';
EXT_TXT_607    constant varchar2(200)	  :=  'Please supply a';
EXT_TXT_608    constant varchar2(200)	  :=  'Please supply an';
EXT_TXT_609    constant varchar2(200)	  :=  'Invalid Name Entered.';
EXT_TXT_610    constant varchar2(200)	  :=  'Invalid Street Entered.';

EXT_TXT_611    constant varchar2(200)	  :=  'Invalid Email Address Entered.';
EXT_TXT_612    constant varchar2(200)	  :=  'Invalid Email Address Entered.';
EXT_TXT_613    constant varchar2(200)	  :=  'Invalid Phone Number Entered.';
EXT_TXT_614    constant varchar2(200)	  :=  'Invalid Post Code Entered.';
EXT_TXT_615    constant varchar2(200)	  :=  'The Information Supplied is Incorrect';
EXT_TXT_616    constant varchar2(300)	  :=  'After the Merchant Details have been entered, some Browsers will Display a message about accessing a non-secure site. Ignore this message and press <B>Yes</B> to return and display the Receipt Page.';
EXT_TXT_617    constant varchar2(200)	  :=  'Duplicate Merchant Order';
EXT_TXT_618    constant varchar2(200)	  :=  'Customer Rings to Place Order';
EXT_TXT_619    constant varchar2(200)	  :=  'Photographer Rings Customer';
EXT_TXT_620    constant varchar2(200)	  :=  'Payment';

EXT_TXT_621    constant varchar2(200)	  :=  'Special Instructions';
EXT_TXT_622    constant varchar2(200)	  :=  'Edit address/details';
EXT_TXT_623    constant varchar2(200)	  :=  'Data Transfer Charge';
EXT_TXT_624    constant varchar2(200)	  :=  'Rate $ per Mb';
EXT_TXT_625    constant varchar2(200)	  :=  'Transfer Data to Primary Site';
EXT_TXT_626    constant varchar2(200)	  :=  'Transfer From Primary Site';
EXT_TXT_627    constant varchar2(200)	  :=  'Stored in the Database';
EXT_TXT_628    constant varchar2(200)	  :=  'Stored on FTP Server';
EXT_TXT_629    constant varchar2(200)	  :=  'Stored using RPC';
EXT_TXT_630    constant varchar2(200)	  :=  'Web Quality can be Emailed at any time. Images can still be purchased.';

EXT_TXT_631    constant varchar2(200)	  :=  'Action Cancelled';
EXT_TXT_632    constant varchar2(200)	  :=  'Modification not performed. Order Style is locked.';
EXT_TXT_633    constant varchar2(200)	  :=  'Is Locked from being accidently changed';
EXT_TXT_634    constant varchar2(200)	  :=  'Matte Border Style';
EXT_TXT_635    constant varchar2(200)	  :=  '(Note: Only supported in Browsers that support style sheets';
EXT_TXT_636    constant varchar2(200)	  :=  'Category Listing: Anchor Colour';
EXT_TXT_637    constant varchar2(200)	  :=  'Category Listing: Anchor Font';
EXT_TXT_638    constant varchar2(200)	  :=  'Category Listing: Anchor Adjust Font Size By';
EXT_TXT_639    constant varchar2(200)	  :=  'Category Listing: Anchor Type';
EXT_TXT_640    constant varchar2(200)	  :=  'No Access to any Novelties';

EXT_TXT_641    constant varchar2(200)	  :=  'Average Connection Time (Minutes)';
EXT_TXT_642    constant varchar2(200)	  :=  'Setup Validation';
EXT_TXT_643    constant varchar2(200)	  :=  'Check Command';
EXT_TXT_644    constant varchar2(200)	  :=  'Check Result';
EXT_TXT_645    constant varchar2(200)	  :=  'Passed';
EXT_TXT_646    constant varchar2(200)	  :=  'Failed';
EXT_TXT_647    constant varchar2(200)	  :=  'Unable to Determine';
EXT_TXT_648    constant varchar2(200)	  :=  'Display Novelties';
EXT_TXT_649    constant varchar2(200)	  :=  'Bulk Image Load';
EXT_TXT_650    constant varchar2(200)	  :=  'Bulk Attach Images';

EXT_TXT_651    constant varchar2(200)	  :=  'Bulk Meta Data Load';
EXT_TXT_652    constant varchar2(200)	  :=  'Load Multiple Original Images';
EXT_TXT_653    constant varchar2(200)	  :=  'Replace Web Quality Images';
EXT_TXT_654    constant varchar2(200)	  :=  'Look for Originals based on Filename';
EXT_TXT_655    constant varchar2(200)	  :=  'Use Download Price Book to attach extensions to Filename';
EXT_TXT_656    constant varchar2(200)	  :=  'Manage Portlets';
EXT_TXT_657    constant varchar2(200)	  :=  'Return URL';
EXT_TXT_658    constant varchar2(200)	  :=  'Text for Return URL (or GIF Name)';
EXT_TXT_659    constant varchar2(200)	  :=  'Extra HTML Code for BODY Tag';
EXT_TXT_660    constant varchar2(200)	  :=  'Menu Bar Title';

EXT_TXT_661    constant varchar2(200)	  :=  'Header Title';
EXT_TXT_662    constant varchar2(200)	  :=  'Text Justify';
EXT_TXT_663    constant varchar2(200)	  :=  'Display Column Headings';
EXT_TXT_664    constant varchar2(200)	  :=  'Account Counter';
EXT_TXT_665    constant varchar2(200)	  :=  'Returl URL is a GIF';
EXT_TXT_666    constant varchar2(200)	  :=  'Instruction Text Header';
EXT_TXT_667    constant varchar2(200)	  :=  'Date Held';
EXT_TXT_668    constant varchar2(200)	  :=  'Instruction Text Footer';
EXT_TXT_669    constant varchar2(200)	  :=  'Account is Enabled';
EXT_TXT_670    constant varchar2(200)	  :=  'Javascript Code';

EXT_TXT_671    constant varchar2(200)	  :=  'Table Definition HTML';
EXT_TXT_672    constant varchar2(200)	  :=  'Table Cell HTML';
EXT_TXT_673    constant varchar2(200)	  :=  'Alternating Row Cell HTML';
EXT_TXT_674    constant varchar2(200)	  :=  'Search Username Value';
EXT_TXT_675    constant varchar2(200)	  :=  'Search Account Name Value';
EXT_TXT_676    constant varchar2(200)	  :=  'Search Job Ref Value';
EXT_TXT_677    constant varchar2(200)	  :=  'Search Business Feature Value';
EXT_TXT_678    constant varchar2(200)	  :=  'Account Must Images';
EXT_TXT_679    constant varchar2(200)	  :=  'Accounts can have already Expired';
EXT_TXT_680    constant varchar2(200)	  :=  'Accounts can already be Disabled';

EXT_TXT_681    constant varchar2(200)	  :=  'Anchor Font';
EXT_TXT_682    constant varchar2(200)	  :=  'Anchor Font Colour';
EXT_TXT_683    constant varchar2(200)	  :=  'Anchor Pitch';
EXT_TXT_684    constant varchar2(200)	  :=  'Text Font';
EXT_TXT_685    constant varchar2(200)	  :=  'Text Font Colour';
EXT_TXT_686    constant varchar2(200)	  :=  'Text Pitch';
EXT_TXT_687    constant varchar2(200)	  :=  'Save Portlet';
EXT_TXT_688    constant varchar2(200)	  :=  'Create New Portlet';
EXT_TXT_689    constant varchar2(200)	  :=  'Delete Portlet';
EXT_TXT_690    constant varchar2(200)	  :=  'Existing Portlets';

EXT_TXT_691    constant varchar2(200)	  :=  'New Name not Specified';
EXT_TXT_692    constant varchar2(200)	  :=  'Portlet Copied to';
EXT_TXT_693    constant varchar2(200)	  :=  'Copy Portlet';
EXT_TXT_694    constant varchar2(200)	  :=  'Portlet Renamed';
EXT_TXT_695    constant varchar2(200)	  :=  'Rename Portlet';
EXT_TXT_696    constant varchar2(200)	  :=  'Portlet Deleted';
EXT_TXT_697    constant varchar2(200)	  :=  'Portlet Not Found';
EXT_TXT_698    constant varchar2(200)	  :=  'Portlet Details Modified';
EXT_TXT_699    constant varchar2(200)	  :=  'Finished Managing Portlets';
EXT_TXT_700    constant varchar2(200)	  :=  'Return without Modification';

EXT_TXT_701    constant varchar2(200)	  :=  'Modify Portlet Definition';
EXT_TXT_702    constant varchar2(200)	  :=  'HMTL Coding';
EXT_TXT_703    constant varchar2(200)	  :=  'Text Display';
EXT_TXT_704    constant varchar2(200)	  :=  'Image Total';
EXT_TXT_705    constant varchar2(200)	  :=  'Counter';
EXT_TXT_706    constant varchar2(200)	  :=  'Display Column Headers';
EXT_TXT_707    constant varchar2(200)	  :=  'Titles and Columns';
EXT_TXT_708    constant varchar2(200)	  :=  'Display';
EXT_TXT_709    constant varchar2(200)	  :=  'Search Options';
EXT_TXT_710    constant varchar2(200)	  :=  'Test/Display Portlet';

EXT_TXT_711    constant varchar2(200)	  :=  'You must provide a portlet name';
EXT_TXT_712    constant varchar2(200)	  :=  'Did not find Portlet';
EXT_TXT_713    constant varchar2(200)	  :=  'Type of Portlet';
EXT_TXT_714    constant varchar2(200)	  :=  'Header Colour';
EXT_TXT_715    constant varchar2(200)	  :=  'Header Font Colour';
EXT_TXT_716    constant varchar2(200)	  :=  'Cell Colour';
EXT_TXT_717    constant varchar2(200)	  :=  'Cell Colour Alternative';
EXT_TXT_718    constant varchar2(200)	  :=  'Portlet Not Found';
EXT_TXT_719    constant varchar2(200)	  :=  'Disabled';
EXT_TXT_720    constant varchar2(200)	  :=  'Expired on';

EXT_TXT_721    constant varchar2(200)	  :=  'Expires on';
EXT_TXT_722    constant varchar2(200)	  :=  'Submit Button Text';
EXT_TXT_723    constant varchar2(200)	  :=  'Login HTML Target';
EXT_TXT_724    constant varchar2(200)	  :=  'Return HTML Target';
EXT_TXT_725    constant varchar2(200)	  :=  'Accounts do not have to be Public';
EXT_TXT_726    constant varchar2(200)	  :=  'Re-Index Meta Data';
EXT_TXT_727    constant varchar2(200)	  :=  'Meta Data Index has been recreated';
EXT_TXT_728    constant varchar2(200)	  :=  'Error Indexing Meta Data';
EXT_TXT_729    constant varchar2(200)	  :=  'Default Value';
EXT_TXT_730    constant varchar2(200)	  :=  'Search for Categories';

EXT_TXT_731    constant varchar2(200)	  :=  'Other Icons';
EXT_TXT_732    constant varchar2(200)	  :=  '<B>Key<B>: <B>P</B> - Photographer, <B>O</B> - Owner, <B>G</B> - Guest';
EXT_TXT_733    constant varchar2(200)	  :=  'Phg/Client Options';
EXT_TXT_734    constant varchar2(200)	  :=  'Thumbnail Grid';
EXT_TXT_735    constant varchar2(200)	  :=  'Details Thumbnail Parameters';

/*
   BKN_ constants refer to the BOOKING module
*/

-- System wide constants
BKN_TXT_000_001 constant varchar2(200)    :=  'Book a facilitated program';
BKN_TXT_000_002 constant varchar2(200)    :=  'Book a self guided tour';
BKN_TXT_000_003 constant varchar2(200)    :=  'This booking is no longer active!';
BKN_TXT_000_004 constant varchar2(200)    :=  'There seem to be no calendar defined for this customer';
BKN_TXT_000_005 constant varchar2(200)    :=  'Your booking has been deleted, inform your administrator of this error before trying again';

-- Screen BKN001
BKN_TXT_001_001 constant varchar2(200)    :=  '<p>Number of students:';
BKN_TXT_001_002 constant varchar2(200)    :=  '<p>Select the <a href="#">type of visit</a>:';
BKN_TXT_001_003 constant varchar2(200)    :=  '<p>When would you like to visit?';

BKN_TXT_001_993 constant varchar2(200)    :=  'The date is in the past';
BKN_TXT_001_994 constant varchar2(200)    :=  'Invalid time given, choose a later time';
BKN_TXT_001_995 constant varchar2(200)    :=  'Invalid time given, choose an earlier time';
BKN_TXT_001_996 constant varchar2(200)    :=  'The date is invalid for this visit type';
BKN_TXT_001_997 constant varchar2(200)    :=  'There is no calendar active for the chosen date';
BKN_TXT_001_998 constant varchar2(200)    :=  'Please specify number of students';
BKN_TXT_001_999 constant varchar2(200)    :=  'Please use numeric characters';

-- Screen BKN002
BKN_TXT_002_001 constant varchar2(200)    :=  '<p>Select your arrival time:</p>';
BKN_TXT_002_002 constant varchar2(200)    :=  'Time available';
BKN_TXT_002_003 constant varchar2(200)    :=  'Time negotiable';
BKN_TXT_002_004 constant varchar2(200)    :=  'Time booked';
BKN_TXT_002_005 constant varchar2(200)    :=  '[Previous Day]';
BKN_TXT_002_006 constant varchar2(200)    :=  '[Next Day]';

-- Screen BKN003
BKN_TXT_003_001 constant varchar2(200)    :=  'Enter visit details';
BKN_TXT_003_002 constant varchar2(200)    :=  'School';
BKN_TXT_003_003 constant varchar2(200)    :=  'Visit details';
BKN_TXT_003_004 constant varchar2(200)    :=  'Date';
BKN_TXT_003_005 constant varchar2(200)    :=  'Time';
BKN_TXT_003_006 constant varchar2(200)    :=  'Year level';
BKN_TXT_003_007 constant varchar2(200)    :=  'Teacher details';
BKN_TXT_003_008 constant varchar2(200)    :=  'Name';
BKN_TXT_003_009 constant varchar2(200)    :=  'E-mail address';
BKN_TXT_003_010 constant varchar2(200)    :=  'Any comments or special needs?';
BKN_TXT_003_011 constant varchar2(200)    :=  'To';
BKN_TXT_003_012 constant varchar2(200)    :=  'Click to select a school';

BKN_TXT_003_997 constant varchar2(200)    :=  'Please select a school';
BKN_TXT_003_998 constant varchar2(200)    :=  'Please select a year level from';
BKN_TXT_003_999 constant varchar2(200)    :=  'Please specify teacher e-mail';

-- Screen BKN004
BKN_TXT_004_001 constant varchar2(200)    :=  'Choose your program(s)';
BKN_TXT_004_002 constant varchar2(200)    :=  'Allocate your <NUMBER_OF_STUDENTS> to one or more programs';
BKN_TXT_004_003 constant varchar2(200)    :=  'Number of students';
BKN_TXT_004_004 constant varchar2(200)    :=  'Program';
BKN_TXT_004_005 constant varchar2(200)    :=  'Year level';
BKN_TXT_004_006 constant varchar2(200)    :=  'More info';

BKN_TXT_004_997 constant varchar2(200)    :=  'Please nominate a program for each of your students';
BKN_TXT_004_998 constant varchar2(200)    :=  '';
BKN_TXT_004_999 constant varchar2(200)    :=  '';

BKN_TXT_001    constant varchar2(200)     :=  'Education Programs';
BKN_TXT_002    constant varchar2(200)     :=  'Paid Program';
BKN_TXT_003    constant varchar2(200)     :=  'Self Guided';
BKN_TXT_004    constant varchar2(200)     :=  'Pre Booking';
BKN_TXT_005    constant varchar2(200)     :=  'Reservation';
BKN_TXT_006    constant varchar2(200)     :=  'Full Booking';
BKN_TXT_007    constant varchar2(200)     :=  '[Select Other]';
BKN_TXT_008    constant varchar2(200)     :=  'Click here to book for the following date and time:';
BKN_TXT_009    constant varchar2(200)     :=  'Cancelled';
BKN_TXT_010    constant varchar2(200)     :=  'Visit Details';
BKN_TXT_011    constant varchar2(200)     :=  'Enter number of students';
BKN_TXT_012    constant varchar2(200)     :=  'Choose a time';
BKN_TXT_013    constant varchar2(200)     :=  'Teacher Details';
BKN_TXT_014    constant varchar2(200)     :=  'School details';
BKN_TXT_015    constant varchar2(200)     :=  'Company details';
BKN_TXT_016    constant varchar2(200)     :=  'Do you want to create a booking on behalf of a school or a bus company?';
BKN_TXT_017    constant varchar2(200)     :=  'Payment details';
BKN_TXT_018    constant varchar2(200)     :=  'Check your details';
BKN_TXT_019    constant varchar2(200)     :=  'Manage booking details';
BKN_TXT_020    constant varchar2(200)     :=  'School';
BKN_TXT_021    constant varchar2(200)     :=  'Click to delete';
BKN_TXT_022    constant varchar2(200)     :=  'Bus Company';
BKN_TXT_023    constant varchar2(200)     :=  'Select programs';
BKN_TXT_024    constant varchar2(200)     :=  'ID';
BKN_TXT_025    constant varchar2(200)     :=  'Title';
BKN_TXT_026    constant varchar2(200)     :=  'Description';
BKN_TXT_028    constant varchar2(200)     :=  'Duration';
BKN_TXT_029    constant varchar2(200)     :=  'Cost per Head';
BKN_TXT_030    constant varchar2(200)     :=  'Suitable for Years';
BKN_TXT_027    constant varchar2(200)     :=  'Booking cancelled';
BKN_TXT_031    constant varchar2(200)     :=  'Facilitated Programs *highly recommended*';
BKN_TXT_032    constant varchar2(200)     :=  'Self-guided Programs';
BKN_TXT_033    constant varchar2(200)     :=  'Total cost Ex. GST';
BKN_TXT_034    constant varchar2(200)     :=  'Previous month';
BKN_TXT_035    constant varchar2(200)     :=  'Next month';
BKN_TXT_036    constant varchar2(200)     :=  'Number of students';
BKN_TXT_037    constant varchar2(200)     :=  'Preferred arrival time';
BKN_TXT_038    constant varchar2(200)     :=  'Preferred arrival date';
BKN_TXT_039    constant varchar2(200)     :=  'Select the date on which you would like to visit by clicking on a date in the calendar.';
BKN_TXT_040    constant varchar2(200)     :=  'Click to select a school';
BKN_TXT_041    constant varchar2(200)     :=  'If you cannot find a suitable date and time, you can fill in this form and we will get back to you';
BKN_TXT_042    constant varchar2(200)     :=  'School name or Bus company name';
BKN_TXT_043    constant varchar2(200)     :=  'Contact AWM staff';
BKN_TXT_044    constant varchar2(200)     :=  'Preferred date of visit';
BKN_TXT_045    constant varchar2(200)     :=  'Preferred time of arrival';
BKN_TXT_046    constant varchar2(200)     :=  'Year level';
BKN_TXT_047    constant varchar2(200)     :=  'What''s available for students at the Memorial';
BKN_TXT_048    constant varchar2(200)     :=  'Number of adults';
BKN_TXT_049    constant varchar2(2000)     :=  '<ul>
                                               <li>Facilitated programs are presented in the Memorial''s galleries by Memorial staff.
                                               <li>Many facilitated programs are hands-on, giving students a discovery learning experience.
                                               <li>All programs are curriculum-linked.
                                               <li>Classes are divided into groups of 15 or fewer students.
                                               <li>Customized programs can be designed to suit specific requests.
                                               </ul>';
BKN_TXT_050    constant varchar2(2000)     :=  '<ulp:\oracle\ora817\bin\oradim -edit -sid PRD1 -startmode auto>
                                               <li>Bookings available from 10am to 4pm any day.
                                               <li>Activity books ordered from the bookings officer can be picked up on arrival at the Education Centre.
                                               </ul>';
BKN_TXT_051    constant varchar2(200)     :=  'DD-MM-YYYY';
BKN_TXT_052    constant varchar2(200)     :=  '[Previous Month]';
BKN_TXT_053    constant varchar2(200)     :=  '[Next Month]';
BKN_TXT_054    constant varchar2(200)     :=  'Date from';
BKN_TXT_055    constant varchar2(200)     :=  'Date to';
BKN_TXT_056    constant varchar2(200)     :=  'View the details of your booking';
BKN_TXT_057    constant varchar2(200)     :=  'Track the details of your bookings';
BKN_TXT_058    constant varchar2(200)     :=  'This visit is part of an organised tour';
BKN_TXT_059    constant varchar2(500)     :=  'Select a day and time to visit the AWM. If you cannot find a suitable date and time you can always contact the AWM by clicking on the button ''Contact education officer''.';
BKN_TXT_060    constant varchar2(200)     :=  'Manually';
BKN_TXT_061    constant varchar2(200)     :=  'You can contact the education officer';
BKN_TXT_062    constant varchar2(200)     :=  'Select';
BKN_TXT_063    constant varchar2(200)     :=  'Click to select';
BKN_TXT_064    constant varchar2(2000)    :=  '<P>Your booking request has been sent. Your booking request number is <BOOKING_REQUEST_NUMBER>, use this number to communicate to us about your booking. An email has been sent to <EMAIL_ADDRESS>. It is important to reply to that message so that we will be able to process your booking request.<P>If there are any problems you will be contacted by the AWM staff.<BR><BR>Kind regards,<P>The Education Officer.';
BKN_TXT_065    constant varchar2(200)     :=  'Invoice will be sent to the school';
BKN_TXT_066    constant varchar2(200)     :=  'Invoice will be sent to';
BKN_TXT_067    constant varchar2(200)     :=  'Date of visit';
BKN_TXT_068    constant varchar2(200)     :=  'Time of visit';
BKN_TXT_069    constant varchar2(200)     :=  'Booking ID';
BKN_TXT_070    constant varchar2(200)     :=  'There seem to be no calendar defined for this customer';
BKN_TXT_071    constant varchar2(200)     :=  'Made by';
BKN_TXT_072    constant varchar2(200)     :=  'Type of visit';
BKN_TXT_073    constant varchar2(200)     :=  'Booked programs';
BKN_TXT_074    constant varchar2(200)     :=  'Booked workbooks';
BKN_TXT_075    constant varchar2(200)     :=  'Postcode State';
BKN_TXT_076    constant varchar2(200)     :=  'Your booking has been deleted, inform your administrator of this error before trying again';
BKN_TXT_077    constant varchar2(200)     :=  'The time you have chosen is invalid, try again';
BKN_TXT_078    constant varchar2(200)     :=  'Number of visitors cannot be zero or negative';
BKN_TXT_079    constant varchar2(200)     :=  'The date you have chosen is in the past';
BKN_TXT_080    constant varchar2(200)     :=  'Prevous day';
BKN_TXT_081    constant varchar2(200)     :=  'Next day';
BKN_TXT_082    constant varchar2(200)     :=  'time available';
BKN_TXT_083    constant varchar2(200)     :=  'time available';
BKN_TXT_084    constant varchar2(200)     :=  'Reserved';
BKN_TXT_085    constant varchar2(200)     :=  'Track your booking details';
BKN_TXT_086    constant varchar2(200)     :=  'DAY"<BR>"DD MONTH YYYY';
BKN_TXT_087    constant varchar2(200)     :=  'Reservation Accepted';
BKN_TXT_088    constant varchar2(200)     :=  'Information about your booking';
BKN_TXT_089    constant varchar2(200)     :=  'Date and time of visit';
BKN_TXT_090    constant varchar2(200)     :=  'Calendar';
BKN_TXT_091    constant varchar2(200)     :=  'Week';
BKN_TXT_093    constant varchar2(200)     :=  'Opening time';
BKN_TXT_094    constant varchar2(200)     :=  'Closing time';
BKN_TXT_095    constant varchar2(200)     :=  'Enter the dates of school holidays when the museum has alternate opening times';
BKN_TXT_096    constant varchar2(200)     :=  'Reason';
BKN_TXT_097    constant varchar2(200)     :=  'Calendar Name';
BKN_TXT_098    constant varchar2(200)     :=  'Calendar Start Time';
BKN_TXT_099    constant varchar2(200)     :=  'Calendar End Time';
BKN_TXT_100    constant varchar2(200)     :=  'Time Block in Minutes';
BKN_TXT_101    constant varchar2(200)     :=  'Calendar Expiry Date';
BKN_TXT_102    constant varchar2(200)     :=  'Number of Days to Show';
BKN_TXT_103    constant varchar2(200)     :=  'Personal Contact Details';
BKN_TXT_104    constant varchar2(200)     :=  'Contact Name';
BKN_TXT_105    constant varchar2(200)     :=  'Enter the date and time when the calender cannot be used';
BKN_TXT_106    constant varchar2(200)     :=  'Add dates to exclude';
BKN_TXT_107    constant varchar2(200)     :=  'Add school holiday';
BKN_TXT_108    constant varchar2(200)     :=  'Change Calendar Preferences';
BKN_TXT_109    constant varchar2(200)     :=  'Calendars';
BKN_TXT_110    constant varchar2(200)     :=  'Contact Education Officer';
BKN_TXT_111    constant varchar2(200)     :=  '[Previous Day]';
BKN_TXT_112    constant varchar2(200)     :=  '[Next Day]';
BKN_TXT_113    constant varchar2(200)     :=  'Sorry, your search returned too many matches. Please refine your search and try again';
BKN_TXT_114    constant varchar2(200)     :=  '[BACK]';
BKN_TXT_115    constant varchar2(200)     :=  '[NEXT]';
BKN_TXT_116    constant varchar2(200)     :=  '[CANCEL]';
BKN_TXT_117    constant varchar2(200)     :=  'Maintain Bus Companies';
BKN_TXT_118    constant varchar2(200)     :=  'To be able to maintain the company profiles there need to be a client and customer defined as a default to be used.<BR><BR>See standard settings for the school bookings.';
BKN_TXT_119    constant varchar2(200)     :=  'Filter Attributes';

BKN_TXT_120    constant varchar2(200)     :=  'Maintain Company Information';
BKN_TXT_121    constant varchar2(200)     :=  'Update Company Data';
BKN_TXT_122    constant varchar2(200)     :=  'Insert New Company';
BKN_TXT_123    constant varchar2(200)     :=  'Delete Company';

BKN_TXT_124    constant varchar2(200)     :=  'ID';
BKN_TXT_125    constant varchar2(200)     :=  'Name';
BKN_TXT_126    constant varchar2(200)     :=  'Street';
BKN_TXT_127    constant varchar2(200)     :=  'Suburb';
BKN_TXT_128    constant varchar2(200)     :=  'City';
BKN_TXT_129    constant varchar2(200)     :=  'Postal Code';
BKN_TXT_130    constant varchar2(200)     :=  'State';
BKN_TXT_131    constant varchar2(200)     :=  'Contact name';
BKN_TXT_132    constant varchar2(200)     :=  'Contact Email';
BKN_TXT_133    constant varchar2(200)     :=  'Contact fax';
BKN_TXT_134    constant varchar2(200)     :=  'Contact phone';
BKN_TXT_135    constant varchar2(200)     :=  'Login Infromation';
BKN_TXT_136    constant varchar2(200)     :=  'Profile user name';
BKN_TXT_137    constant varchar2(200)     :=  'Profile password';
BKN_TXT_138    constant varchar2(200)     :=  'Confirm password';
BKN_TXT_139    constant varchar2(200)     :=  'Profile expiry date';
BKN_TXT_140    constant varchar2(200)     :=  'Profile is active';
BKN_TXT_141    constant varchar2(200)     :=  'Insert And Continue Insert';
BKN_TXT_142    constant varchar2(200)     :=  'Contact Education officer';
BKN_TXT_143    constant varchar2(200)     :=  'Event Name';
BKN_TXT_144    constant varchar2(200)     :=  'This booking is no longer active!';
BKN_TXT_145    constant varchar2(200)     :=  'Closed';
BKN_TXT_146    constant varchar2(200)     :=  'Your request has been sent';
BKN_TXT_147    constant varchar2(200)     :=  'Your request has successfully been sent to ';
BKN_TXT_148    constant varchar2(200)     :=  'School Bookings';
BKN_TXT_149    constant varchar2(200)     :=  'School Attendants';
BKN_TXT_150    constant varchar2(200)     :=  'You have to have at least xx adults to supervise. Click OK and correct the value';
BKN_TXT_151    constant varchar2(200)     :=  'Program';
BKN_TXT_152    constant varchar2(200)     :=  'Number of Students';
BKN_TXT_153    constant varchar2(200)     :=  'Year Level';
BKN_TXT_154    constant varchar2(200)     :=  'Check your details';
BKN_TXT_155    constant varchar2(200)     :=  'Any comments or special needs?';
BKN_TXT_156    constant varchar2(200)     :=  'GST';
BKN_TXT_157    constant varchar2(200)     :=  'Total cost incl. GST';
BKN_TXT_158    constant varchar2(200)     :=  'Invoice will be sent to';
BKN_TXT_159    constant varchar2(200)     :=  'Comments or special needs';
BKN_TXT_160    constant varchar2(200)     :=  'Email';
BKN_TXT_161    constant varchar2(200)     :=  'Phone';
BKN_TXT_162    constant varchar2(200)     :=  'Fax';
BKN_TXT_163    constant varchar2(200)     :=  'Login As';
BKN_TXT_164    constant varchar2(200)     :=  'Click on login to login as receptionist';
BKN_TXT_165    constant varchar2(200)     :=  'Wars Covered';
BKN_TXT_166    constant varchar2(200)     :=  'Curriculum Link';
BKN_TXT_167    constant varchar2(200)     :=  'URL';
BKN_TXT_168    constant varchar2(200)     :=  'Expiry Date';
BKN_TXT_169    constant varchar2(200)     :=  'Program Type';
BKN_TXT_170    constant varchar2(200)     :=  'Info';
BKN_TXT_171    constant varchar2(200)     :=  'Book a Facilitated Program';
BKN_TXT_172    constant varchar2(200)     :=  'Book a Self Guided Tour';
BKN_TXT_173    constant varchar2(200)     :=  'Choose a date';
BKN_TXT_174    constant varchar2(200)     :=  'Enter visit details';
BKN_TXT_175    constant varchar2(200)     :=  'Choose your program(s)';
BKN_TXT_176    constant varchar2(200)     :=  'Allocate your <NUMBER_OF_STUDENTS> students to one or more programs';
BKN_TXT_177    constant varchar2(200)     :=  'Comments';
BKN_TXT_178    constant varchar2(200)     :=  'Please specify number of students';
BKN_TXT_179    constant varchar2(200)     :=  'Please give numeric value for number of students';
BKN_TXT_180    constant varchar2(200)     :=  'Please give numeric value for number of adults';
BKN_TXT_181    constant varchar2(200)     :=  'Please enter your name in Teacher Details';
BKN_TXT_182    constant varchar2(200)     :=  'Please enter your email address in Teacher Details';
BKN_TXT_183    constant varchar2(200)     :=  'Please choose the visiting school from the dropdown list.  If the school is not listed, <ul>contact the Bookings Officer</ul>';
BKN_TXT_184    constant varchar2(200)     :=  'To achieve the minimum adult:student ratio you will need at least <NUMBER_OF_ADULTS> adults';
BKN_TXT_185    constant varchar2(200)     :=  'Please nominate a program for each of your students';
BKN_TXT_186    constant varchar2(200)     :=  'Please indicate whether the school or bus company will be invoiced for the visit';


/* ================================================================================================== */

BKN_TXT_092    constant varchar2(200)     :=  '';

BKN_BUT_003    constant varchar2(200)     :=  'Back';
BKN_BUT_005    constant varchar2(200)     :=  'Contact Education officer';

/*
   PRG_ constants refer to the PROGRAM module
*/
PRG_TXT_001    constant varchar2(200)     :=  'Maintain program information';
PRG_TXT_002    constant varchar2(200)     :=  'Update program data';
PRG_TXT_003    constant varchar2(200)     :=  'Insert new program';
PRG_TXT_004    constant varchar2(200)     :=  'Delete program';

PRG_TXT_100    constant varchar2(200)     :=  'Program ID';
PRG_TXT_101    constant varchar2(200)     :=  'Program name';
PRG_TXT_102    constant varchar2(200)     :=  'Program description';
PRG_TXT_103    constant varchar2(200)     :=  'Duration';
PRG_TXT_104    constant varchar2(200)     :=  'Cost per head';
PRG_TXT_105    constant varchar2(200)     :=  'School year';
PRG_TXT_106    constant varchar2(200)     :=  'Wars covered';
PRG_TXT_107    constant varchar2(200)     :=  'Program type';
PRG_TXT_108    constant varchar2(200)     :=  'PROGRAM'; -- UMO type
PRG_TXT_109    constant varchar2(200)     :=  'WORKBOOK';
PRG_TXT_110    constant varchar2(200)     :=  'Facilitated';

PRG_TXT_111    constant varchar2(200)     :=  'SelfGuided';
PRG_TXT_112    constant varchar2(200)     :=  'Expiry date';
/*
   WRB_ constants refer to the PROGRAM module
*/
WRB_TXT_001    constant varchar2(200)     :=  'Maintain workbook information';
WRB_TXT_002    constant varchar2(200)     :=  'Update workbook data';
WRB_TXT_003    constant varchar2(200)     :=  'Insert new workbook';
WRB_TXT_004    constant varchar2(200)     :=  'Delete workbook';

WRB_TXT_100    constant varchar2(200)     :=  'Workbook ID';
WRB_TXT_101    constant varchar2(200)     :=  'Workbook name';
WRB_TXT_102    constant varchar2(200)     :=  'Workbook description';
WRB_TXT_103    constant varchar2(200)     :=  'Duration';
WRB_TXT_104    constant varchar2(200)     :=  'Cost per head';
WRB_TXT_105    constant varchar2(200)     :=  'School year';
WRB_TXT_106    constant varchar2(200)     :=  'Wars covered';
WRB_TXT_107    constant varchar2(200)     :=  'Workbook type';
/*
 * SCL_ constants refer to the school module
 */
SCL_TXT_001    constant varchar2(200)     :=  'Maintain school information';
SCL_TXT_002    constant varchar2(200)     :=  'Update school data';
SCL_TXT_003    constant varchar2(200)     :=  'Insert new school';
SCL_TXT_004    constant varchar2(200)     :=  'Delete school';

SCL_TXT_100    constant varchar2(200)     :=  'School ID';
SCL_TXT_101    constant varchar2(200)     :=  'School name';
SCL_TXT_102    constant varchar2(200)     :=  'City';
SCL_TXT_103    constant varchar2(200)     :=  'Postal code';
SCL_TXT_104    constant varchar2(200)     :=  'Suburb';
SCL_TXT_105    constant varchar2(200)     :=  'State';
SCL_TXT_106    constant varchar2(200)     :=  'Email address';
SCL_TXT_107    constant varchar2(200)     :=  'Street name';
SCL_TXT_108    constant varchar2(200)     :=  'Phone';
SCL_TXT_109    constant varchar2(200)     :=  'Fax';
SCL_TXT_110    constant varchar2(200)     :=  'Contact name';

SCL_TXT_111    constant varchar2(200)     :=  'Contact phone';
SCL_TXT_112    constant varchar2(200)     :=  'Contact Email';
SCL_TXT_113    constant varchar2(200)     :=  BKN_TXT_021;
SCL_TXT_114    constant varchar2(200)     :=  'del';
SCL_TXT_115    constant varchar2(200)     :=  'Filter attributes';

SCL_BTN_100    constant varchar2(200)     :=  'Empty fields';
SCL_BTN_101    constant varchar2(200)     :=  'Search';

/*
 * STE_ refer to the STATE module
 */
STE_TXT_001    constant varchar2(200)     :=  'Maintain state information';
STE_TXT_002    constant varchar2(200)     :=  'Update state data';
STE_TXT_003    constant varchar2(200)     :=  'Insert new state';
STE_TXT_004    constant varchar2(200)     :=  'Delete state';

STE_TXT_100    constant varchar2(200)     :=  'State ID';
STE_TXT_101    constant varchar2(200)     :=  'State name';
STE_TXT_102    constant varchar2(200)     :=  'State TLW';

/*
 * RSC_ refer to the RESOURCE module
 */
RSC_TXT_001    constant varchar2(200)     :=  'Maintain resource information';
RSC_TXT_002    constant varchar2(200)     :=  'Update resource data';
RSC_TXT_003    constant varchar2(200)     :=  'Insert new resource';
RSC_TXT_004    constant varchar2(200)     :=  'Delete resource';

RSC_TXT_100    constant varchar2(200)     :=  'Resource ID';
RSC_TXT_101    constant varchar2(200)     :=  'Rsource description';
RSC_TXT_102    constant varchar2(200)     :=  'Maximum group size';

/*
 * BCO_ refer to the Bus Company module
 */

/*
 * CAL_ refer to the calendar module
 */
CAL_TXT_001    constant varchar2(200)     :=  'Calendar';
CAL_TXT_002    constant varchar2(200)     :=  'Calendar parameters';
CAL_TXT_003    constant varchar2(200)     :=  'Calendar name';
CAL_TXT_004    constant varchar2(200)     :=  'Manufacturer';
CAL_TXT_005    constant varchar2(200)     :=  'Click on the calendar name to edit';
CAL_TXT_006    constant varchar2(200)     :=  'Create new calendar';

end lng5;

/
