CREATE OR REPLACE package WEBSYS.lng2
as

--
-- English Language Module #2
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
-- PFM
--

PFM_TXT_001	constant varchar2(200)		:=  'Photo Name Key';
PFM_TXT_002	constant varchar2(200)		:=  'Unique Id of the CD containing the Photos';
PFM_TXT_003	constant varchar2(200)		:=  'Unique Id of the Roll of Film';
PFM_TXT_004	constant varchar2(200)		:=  'Name of the Folder on the CD containing a Roll of Film';
PFM_TXT_005	constant varchar2(200)		:=  'The Photograph Number. You can also use';
PFM_TXT_006	constant varchar2(200)		:=  'Specify Details for Loading Photos from a set of CDs';
PFM_TXT_007	constant varchar2(200)		:=  'Photo Name Format Mask';
PFM_TXT_008	constant varchar2(200)		:=  'Convert to';
PFM_TXT_009	constant varchar2(200)		:=  'Photo Quality Compression';
PFM_TXT_010	constant varchar2(200)		:=  'Existing Customer Photos';

PFM_TXT_011	constant varchar2(200)		:=  'Keep them';
PFM_TXT_012	constant varchar2(200)		:=  'Replace photos if the filename is the same';
PFM_TXT_013	constant varchar2(200)		:=  'Delete all photos in the account';
PFM_BUT_014	constant varchar2(200)		:=  'Update Details' ;
PFM_TXT_016	constant varchar2(200)		:=  'Edit CD Details' ;
PFM_TXT_017	constant varchar2(200)		:=  'Insert Details and Edit CD Details';
PFM_TXT_018	constant varchar2(200)		:=  'Form Details Successfully Modified';
PFM_TXT_019	constant varchar2(200)		:=  'Specify CD Details for Loading Photos from a set of CDs';
PFM_TXT_020	constant varchar2(200)		:=  'Enter in the name for this CD (optional) and a four character identifier of this CD';

PFM_TXT_021	constant varchar2(200)		:=  'Edit CD Details';
PFM_TXT_022	constant varchar2(200)		:=  'CD Name';
PFM_TXT_023	constant varchar2(200)		:=  'CD';
PFM_TXT_024	constant varchar2(200)		:=  '[New CD]';
PFM_TXT_025	constant varchar2(200)		:=  'Insert/Update CD Details';
PFM_TXT_026	constant varchar2(200)		:=  'Insert/Update CD Details and Return to Preferences';
PFM_TXT_027	constant varchar2(200)		:=  'Return to Previous Screen';
PFM_TXT_028	constant varchar2(200)		:=  'To Delete an Entry simply empty the CD field';
PFM_TXT_029	constant varchar2(200)		:=  '[Edit CD Details]';
PFM_TXT_030	constant varchar2(200)		:=  'CD Details Successfully Modified';

PFM_TXT_033	constant varchar2(200)		:=  'Folder Name';
PFM_TXT_034	constant varchar2(200)		:=  'Roll Name';
PFM_TXT_035	constant varchar2(200)		:=  'Default Category';
PFM_TXT_036	constant varchar2(200)		:=  'Filename Format';
PFM_TXT_037	constant varchar2(200)		:=  'Photo Load Control';
PFM_TXT_038	constant varchar2(200)		:=  'Where N is the number of digits';
PFM_TXT_039	constant varchar2(200)		:=  'Insert/Update Folder Details';
PFM_TXT_040	constant varchar2(200)		:=  'Insert/Update Folder Details and Return to CD Details';

PFM_TXT_041	constant varchar2(200)		:=  'Folder Details Successfully Modified';
PFM_TXT_042	constant varchar2(200)		:=  'To Delete an Entry simply empty the Folder Id and Roll Id fields';
PFM_TXT_043	constant varchar2(200)		:=  'Store Original Image';
PFM_TXT_044	constant varchar2(200)		:=  'FTP Upload or CD Format';
PFM_TXT_045	constant varchar2(200)		:=  'Define Batch Upload Capability (after FTP Load)';
PFM_TXT_046	constant varchar2(200)		:=  'No Log File Exists';
PFM_TXT_047	constant varchar2(200)		:=  'View Upload Log';
PFM_TXT_048	constant varchar2(200)		:=  'Delete Upload from Job Queue and Define New Upload Job';
PFM_TXT_050	constant varchar2(200)		:=  'Date Submitted';

PFM_TXT_051	constant varchar2(200)		:=  'FTP Load Directory';
PFM_TXT_052	constant varchar2(200)		:=  'Load into Category';
PFM_TXT_053	constant varchar2(200)		:=  'Log File Listing';
PFM_TXT_054	constant varchar2(200)		:=  'Submit a Job to Upload Images';
PFM_TXT_055	constant varchar2(200)		:=  'Submit Job';
PFM_TXT_056	constant varchar2(200)		:=  'Job has been placed on the Queue and will be run as soon as possible';
PFM_TXT_057	constant varchar2(200)		:=  'Invalid Directory Specified. Make sure the spelling and case of the ftp directory is correct';
PFM_TXT_058	constant varchar2(200)		:=  'Batch Job Details (This Job is Waiting to Run)';
PFM_TXT_059	constant varchar2(200)		:=  'Job Status';
PFM_TXT_060	constant varchar2(200)		:=  'Job is Waiting to Run';

PFM_TXT_061	constant varchar2(200)		:=  'Job is Running. Started at time:';
PFM_TXT_062	constant varchar2(200)		:=  'Job has been scheduled to start running';
PFM_TXT_064	constant varchar2(200)		:=  'Fast Checkout Facility';
PFM_TXT_065	constant varchar2(200)		:=  'Fill in the Details below to make your order';
PFM_TXT_066	constant varchar2(200)		:=  'Calculate Order Total';
PFM_TXT_067	constant varchar2(200)		:=  'Public Account (no password required)';
PFM_TXT_068	constant varchar2(200)		:=  'Image is Global';
PFM_TXT_069	constant varchar2(200)		:=  'Global Image Management';
PFM_TXT_070	constant varchar2(200)		:=  'Make Global all Images';

PFM_TXT_071	constant varchar2(200)		:=  'Make Private all Images';
PFM_TXT_072	constant varchar2(200)		:=  'Make Global all Images in category';
PFM_TXT_073	constant varchar2(200)		:=  'Make Private all Images in category';
PFM_TXT_075	constant varchar2(200)		:=  'Images Modified';
PFM_TXT_076	constant varchar2(200)		:=  'Delete All Accounts marked for DELETION';
PFM_TXT_077	constant varchar2(200)		:=  'Send SMS Message when an Order is made';
PFM_TXT_078	constant varchar2(200)		:=  'Send SMS Message only if order is greater in value than';
PFM_TXT_079	constant varchar2(200)		:=  'To Send an SMS Message you need to provide a Mobile Phone Number';
PFM_TXT_080	constant varchar2(200)		:=  'Random Image on Home Page';

PFM_TXT_081	constant varchar2(200)		:=  'Invalid Request to Create Account with Event';
PFM_TXT_082	constant varchar2(200)		:=  'Plan Event does not have sufficient values to create the account.';
PFM_TXT_083	constant varchar2(200)		:=  'This Browser Version is not supported. Minimum Supported Version is';
PFM_TXT_084	constant varchar2(200)		:=  'First Record';
PFM_TXT_085	constant varchar2(200)		:=  'Previous Set';
PFM_TXT_086	constant varchar2(200)		:=  'Previous Record'; -- save ADM_TXT_562
PFM_TXT_087	constant varchar2(200)		:=  'Last Record';
PFM_TXT_088	constant varchar2(200)		:=  'Next Set';
PFM_TXT_089	constant varchar2(200)		:=  'Next Record';
PFM_TXT_090	constant varchar2(200)		:=  'Copy Record';

PFM_TXT_091	constant varchar2(200)		:=  'Edit Record';
PFM_TXT_092	constant varchar2(200)		:=  'Delete Record';
PFM_TXT_093	constant varchar2(200)		:=  'Insert Record';
PFM_TXT_094	constant varchar2(200)		:=  'Query Mode';
PFM_TXT_099	constant varchar2(200)		:=  'Sort Ascending Order';
PFM_TXT_100	constant varchar2(200)		:=  'Sort Descending Order';

PFM_TXT_101	constant varchar2(200)		:=  'Refresh Record';
PFM_TXT_102	constant varchar2(200)		:=  'Total Images';
PFM_TXT_103	constant varchar2(200)		:=  'Customer Contact Details';

PFM_TXT_114	constant varchar2(200)		:=  'Account Password';
PFM_TXT_115	constant varchar2(200)		:=  'Manage Customer Contact and Billing Details';
PFM_TXT_116	constant varchar2(200)		:=  'Modify Customer Details';
PFM_TXT_117	constant varchar2(200)		:=  'Pay using Account';
PFM_TXT_118	constant varchar2(200)		:=  'Invalid Account Password Entered';
PFM_TXT_119	constant varchar2(200)		:=  'Run a Report';
PFM_TXT_120	constant varchar2(200)		:=  'Run';

PFM_TXT_121	constant varchar2(200)		:=  'Run Now';
PFM_TXT_122	constant varchar2(200)		:=  'Run Once at';
PFM_TXT_123	constant varchar2(200)		:=  'Run Every';
PFM_TXT_124	constant varchar2(200)		:=  'Run Once a Week on';
PFM_TXT_125	constant varchar2(200)		:=  'Run Once a Month on';
PFM_TXT_126	constant varchar2(200)		:=  'Weekday';
PFM_TXT_127	constant varchar2(200)		:=  'Business Day';
PFM_TXT_129	constant varchar2(200)		:=  'Last Day';

PFM_TXT_131	constant varchar2(200)		:=  'Days to Autoexpire Report';
PFM_TXT_132	constant varchar2(200)		:=  'Email Notification when Run Completed';
PFM_TXT_133	constant varchar2(200)		:=  'Submit Report';
PFM_TXT_134	constant varchar2(200)		:=  'Report Details';
PFM_TXT_135	constant varchar2(200)		:=  'No Notification';
PFM_TXT_136	constant varchar2(200)		:=  'SMS Notification when Run Completed';
PFM_TXT_137	constant varchar2(200)		:=  'Email Report when Run Completed';
PFM_TXT_138	constant varchar2(200)		:=  'Report Queue';
PFM_TXT_139	constant varchar2(200)		:=  'Completed';
PFM_TXT_140	constant varchar2(200)		:=  'Waiting';

PFM_TXT_141	constant varchar2(200)		:=  'Running';
PFM_TXT_142	constant varchar2(200)		:=  'Purge';
PFM_TXT_143	constant varchar2(200)		:=  'Sort Date';
PFM_TXT_144	constant varchar2(200)		:=  'Report Contains no Data';
PFM_TXT_145	constant varchar2(200)		:=  'Report File was not found';
PFM_TXT_146	constant varchar2(200)		:=  'Reports Purged';
PFM_TXT_147	constant varchar2(200)		:=  'Sort Name';
PFM_TXT_148	constant varchar2(200)		:=  'Sort Category';
PFM_TXT_149	constant varchar2(200)		:=  'View';
PFM_TXT_150	constant varchar2(200)		:=  'Email Report';

PFM_TXT_151	constant varchar2(200)		:=  'Job Run Statistics';
PFM_TXT_152	constant varchar2(200)		:=  'Move';
PFM_TXT_153	constant varchar2(200)		:=  'Security';
PFM_TXT_154	constant varchar2(200)		:=  'Copy';
PFM_TXT_155	constant varchar2(200)		:=  'Report Utilities';
PFM_TXT_156	constant varchar2(200)		:=  'Shared Report';
PFM_TXT_157	constant varchar2(200)		:=  'Parameters on the Queue';
PFM_TXT_158	constant varchar2(200)		:=  'Process';
PFM_TXT_160	constant varchar2(200)		:=  'Public';

PFM_TXT_161	constant varchar2(200)		:=  'Create Report';
PFM_TXT_162	constant varchar2(200)		:=  'Manufacturer Images not Attached to a Product';
PFM_TXT_163	constant varchar2(200)		:=  'Delete Images';
PFM_TXT_164	constant varchar2(200)		:=  'Top Frame Business Feature';
PFM_TXT_168	constant varchar2(200)		:=  'Global';
PFM_TXT_169	constant varchar2(200)		:=  'Stem';
PFM_TXT_170	constant varchar2(200)		:=  'Global Search';

--
-- FRM
--

FRM_TXT_001	constant varchar2(200)		:=  'HIERARCHY';
FRM_TXT_002	constant varchar2(200)		:=  'FRAMES';
FRM_TXT_003	constant varchar2(200)		:=  'FRAMES REVERSED';
FRM_TXT_004	constant varchar2(200)		:=  'LARGE MESSAGE BOX';
FRM_TXT_005	constant varchar2(200)		:=  'Please Choose a Forum';
FRM_TXT_006	constant varchar2(200)		:=  'Post Message';
FRM_TXT_007	constant varchar2(200)		:=  'Search this Forum';
FRM_TXT_008	constant varchar2(200)		:=  'Sort';
FRM_TXT_009	constant varchar2(200)		:=  'By Date';
FRM_TXT_010	constant varchar2(200)		:=  'By Owner';

FRM_TXT_011	constant varchar2(200)		:=  'Result of Search for';
FRM_TXT_012	constant varchar2(200)		:=  'There are no responses to this thread';
FRM_TXT_013	constant varchar2(200)		:=  'Your new Forum has been created';
FRM_TXT_014	constant varchar2(200)		:=  'Press to Refresh the listing of Forums' ;
FRM_TXT_015	constant varchar2(200)		:=  'Submitted by';
FRM_TXT_016	constant varchar2(200)		:=  'on';
FRM_TXT_017	constant varchar2(200)		:=  'Create New Forum';
FRM_TXT_018	constant varchar2(200)		:=  'Your Response has been added to this thread';
FRM_TXT_019	constant varchar2(200)		:=  'Your Response could not be saved because of an internal error. It has been logged and will be fixed asap.';
FRM_TXT_020	constant varchar2(200)		:=  'This Forum Already Exists. Please try a different name.';

FRM_TXT_021	constant varchar2(200)		:=  'This Thread matches to the name of a Forum group. Please try a different name.';
FRM_TXT_022	constant varchar2(200)		:=  'Your Session has been lost. Please reconnect.';
FRM_TXT_023	constant varchar2(200)		:=  'Your Forum name did not pass by the internal censor. Please try a different name.';
FRM_TXT_024	constant varchar2(200)		:=  'Please enter in a response for this newly created forum';
FRM_TXT_025	constant varchar2(200)		:=  'A response must have text in it. Please enter in a response';
FRM_TXT_026	constant varchar2(200)		:=  'Attach Thread to';
FRM_TXT_027	constant varchar2(200)		:=  'Thread Name';
FRM_TXT_028	constant varchar2(200)		:=  'Add New Forum and Post Message';
FRM_TXT_029	constant varchar2(200)		:=  'Post Reply';
FRM_TXT_030	constant varchar2(200)		:=  'Text is limited to 1000 Character, and please keep it clean.';

FRM_TXT_031	constant varchar2(200)		:=  're';
FRM_TXT_032	constant varchar2(200)		:=  'Subject';
FRM_TXT_033	constant varchar2(200)		:=  'Post Message to Forum';
FRM_TXT_034	constant varchar2(200)		:=  'Posted by';
FRM_TXT_035	constant varchar2(200)		:=  'Reply to this Post';
FRM_TXT_036	constant varchar2(200)		:=  'Forum';
FRM_TXT_037	constant varchar2(200)		:=  'Your Search did not find anything' ;
FRM_TXT_038	constant varchar2(200)		:=  'Database Chat-Guestbook';
FRM_TXT_039	constant varchar2(200)		:=  'Display messages since';
FRM_TXT_040	constant varchar2(200)		:=  'Last 24 hours';

FRM_TXT_041	constant varchar2(200)		:=  'Last 7 Days';
FRM_TXT_042	constant varchar2(200)		:=  'Last Visit';
FRM_TXT_043	constant varchar2(200)		:=  'All Messages';
FRM_TXT_044	constant varchar2(200)		:=  'Minimise Listing';
FRM_TXT_045	constant varchar2(200)		:=  'Post a new message';
FRM_TXT_046	constant varchar2(200)		:=  'Update Chat Forum Style';
FRM_TXT_047	constant varchar2(200)		:=  'Forum Style';
FRM_TXT_049	constant varchar2(200)		:=  'GUESTBOOK';
FRM_TXT_050	constant varchar2(200)		:=  'Delete Message';

FRM_TXT_051	constant varchar2(200)		:=  'Delete Forum';
FRM_TXT_052	constant varchar2(200)		:=  'Message Deleted';
FRM_TXT_053	constant varchar2(200)		:=  'Post to Forum';
FRM_TXT_054	constant varchar2(200)		:=  'Enable Stem Search';

--
-- PBK
--

PBK_TXT_001	constant varchar2(200)		:= '<PHOTOGRAPHER> Price Book';
PBK_TXT_002	constant varchar2(200)		:= 'Click on Price Book Name to Manage the Price Book Items';
PBK_TXT_003	constant varchar2(200)		:= 'Price Book Name';
PBK_TXT_005	constant varchar2(200)		:= 'To Select a Manufacturer highlight the Manufacturer''s name.<BR>Multiple Manufacturer''s can be chosen.';
PBK_TXT_006	constant varchar2(200)		:= 'Price Book Name cannot be empty';
PBK_TXT_007	constant varchar2(200)		:= 'Create New Price Book';
PBK_TXT_008	constant varchar2(200)		:= 'Book Name';
PBK_TXT_009	constant varchar2(200)		:= 'Manufacturer';

PBK_TXT_012	constant varchar2(200)		:= 'Create';
PBK_TXT_014	constant varchar2(200)		:= 'Detailed Report';
PBK_TXT_015	constant varchar2(200)		:= 'Best Sellers';
PBK_TXT_016	constant varchar2(200)		:= 'Price Book Created';
PBK_TXT_017	constant varchar2(200)		:= 'Items';
PBK_TXT_018	constant varchar2(200)		:= 'Item Summary Report';
PBK_TXT_019	constant varchar2(200)		:= 'Create a new Item';
PBK_TXT_020	constant varchar2(200)		:= 'Edit Item';

PBK_TXT_021	constant varchar2(200)		:= 'Item Description';
PBK_TXT_023	constant varchar2(200)		:= 'Item Code';
PBK_TXT_024	constant varchar2(200)		:= 'Is Default';
PBK_TXT_028	constant varchar2(200)		:= 'Total Mfctr Cost';
PBK_TXT_029	constant varchar2(200)		:= 'Lab Discount on this item is ';
PBK_TXT_030	constant varchar2(200)		:= 'Insert new Item';

PBK_TXT_031	constant varchar2(200)		:= 'Modify Item';
PBK_TXT_032	constant varchar2(200)		:= 'Delete Item';
PBK_TXT_033	constant varchar2(200)		:= 'Item Successfuly Modified';
PBK_TXT_034	constant varchar2(200)		:= 'Year';
PBK_TXT_035	constant varchar2(200)		:= 'Month';
PBK_TXT_036	constant varchar2(200)		:= 'Orders Made';
PBK_TXT_039	constant varchar2(200)		:= 'Price Book has been Deleted';
PBK_TXT_040	constant varchar2(200)		:= 'The following customers reference this price book';


PBK_TXT_041	constant varchar2(200)		:= 'A Price Book can only be deleted when no customers reference it';
PBK_TXT_042	constant varchar2(200)		:= 'The Price Book';
PBK_TXT_043	constant varchar2(200)		:= ' already exists';
PBK_TXT_044	constant varchar2(200)		:= 'Min Quantity';
PBK_TXT_045	constant varchar2(200)		:= 'Max Quantity';
PBK_TXT_046	constant varchar2(200)		:= 'Create Item';
PBK_TXT_047	constant varchar2(200)		:= 'Optional: Minimum and Maximum Quantity';
PBK_TXT_048	constant varchar2(200)		:= 'Specify minimum and maximum quantity that must be ordered by the customer for this item price to be used.';
PBK_TXT_049	constant varchar2(200)		:= 'i. Leave empty if there are no limits. ie. The price is valid irrespective of the quantity ordered.';
PBK_TXT_050	constant varchar2(200)		:= 'ii. If a minimum value is specified then a blank maximum value assumes unlimited.';

PBK_TXT_051	constant varchar2(200)		:= 'iii. If a maximum value is specified then a blank minimum value assumes the number 1.';
PBK_TXT_052	constant varchar2(200)		:= 'iv. Remember to specify the price for one item and not the total quantity.';
PBK_TXT_053	constant varchar2(200)		:= 'Min Qty';
PBK_TXT_054	constant varchar2(200)		:= 'Max Qty';
PBK_TXT_055	constant varchar2(200)		:= 'Cannot choose this option. You must specify a minimum order quantity of ';
PBK_TXT_056	constant varchar2(200)		:= 'Cannot choose this option. The quantity ordered exceed the maximum of ';
PBK_TXT_057	constant varchar2(200)		:= 'Click to View Full Size Image';
PBK_TXT_058	constant varchar2(200)		:= 'Attach Price Book to a Category';
PBK_TXT_059	constant varchar2(200)		:= 'Attach this Price Book';
PBK_TXT_060	constant varchar2(200)		:= 'Quick Create';

PBK_TXT_061	constant varchar2(200)		:= 'Special Moments';
PBK_TXT_062	constant varchar2(200)		:= 'Category Renamed. Click to Return';
PBK_TXT_064	constant varchar2(200)		:= 'Colour High';
PBK_TXT_065	constant varchar2(200)		:= 'Colour Low';
PBK_TXT_066	constant varchar2(200)		:= 'Number';
PBK_TXT_067	constant varchar2(200)		:= 'Bar';
PBK_TXT_068	constant varchar2(200)		:= 'Linked To';
PBK_TXT_069	constant varchar2(200)		:= 'Attach/Remove/Reset Linked Images and Documents';
PBK_TXT_070	constant varchar2(200)		:= 'Attach New Link';

PBK_TXT_071	constant varchar2(200)		:= 'Remove Link';
PBK_TXT_072	constant varchar2(200)		:= 'Reset Link Weighting';
PBK_TXT_074	constant varchar2(200)		:= 'Weighting';
PBK_TXT_075	constant varchar2(200)		:= 'Last Access';
PBK_TXT_076	constant varchar2(200)		:= 'Connections';
PBK_TXT_077	constant varchar2(200)		:= 'Derived Value';
PBK_TXT_079	constant varchar2(200)		:= '<PHOTOGRAPHER> Personal Preferences';
PBK_TXT_080	constant varchar2(200)		:= 'NOVICE';

PBK_TXT_081	constant varchar2(200)		:= 'INTERMEDIATE';
PBK_TXT_082	constant varchar2(200)		:= 'ADVANCED';
PBK_TXT_083	constant varchar2(200)		:= 'Skill Level';
PBK_TXT_084	constant varchar2(200)		:= 'I Accept these Terms and Conditions';
PBK_TXT_085	constant varchar2(200)		:= 'I DO NOT Accept these Terms and Conditions';
PBK_TXT_086	constant varchar2(200)		:= 'Click on Image Name to Edit Link Details';
PBK_TXT_087	constant varchar2(200)		:= 'No Links Found';
PBK_TXT_088	constant varchar2(200)		:= 'Link Control';
PBK_TXT_089	constant varchar2(200)		:= 'Link Details Successfully Modified';
PBK_TXT_090	constant varchar2(200)		:= 'See Also';

PBK_TXT_092	constant varchar2(200)		:= 'The Image Format could not be Determined';
PBK_TXT_093	constant varchar2(200)		:= 'There are more than 1000 Images in this account. Too many to display. Must specify Load ID manually instead.';
PBK_TXT_094	constant varchar2(200)		:= 'Delete Images, Backups, Details';
PBK_TXT_095	constant varchar2(200)		:= 'Delete all Disabled Images';
PBK_TXT_096	constant varchar2(200)		:= 'Delete all Enabled Images';
PBK_TXT_097	constant varchar2(200)		:= 'Delete images in category';
PBK_TXT_098	constant varchar2(200)		:= 'To Delete, type the word DELETE in uppercase, and check the delete activity required.';
PBK_TXT_099	constant varchar2(200)		:= 'Type DELETE here';
PBK_TXT_100	constant varchar2(200)		:= 'Word DELETE not entered. Delete action not performed';

PBK_TXT_101	constant varchar2(200)		:= 'Mandatory Tag Value not supplied';
PBK_TXT_102	constant varchar2(200)		:= 'Tag length exceeds maximum length of ';
PBK_TXT_103	constant varchar2(200)		:= 'Tag not part of List of Values';
PBK_TXT_104	constant varchar2(200)		:= 'Tag is not a number';
PBK_TXT_105	constant varchar2(200)		:= 'Tag is not a Integer';
PBK_TXT_106	constant varchar2(200)		:= 'Tag is not of date format';
PBK_TXT_107	constant varchar2(200)		:= 'Tag is not of time format';
PBK_TXT_108	constant varchar2(200)		:= 'Tag is of type VARCHAR';
PBK_TXT_109	constant varchar2(200)		:= 'Tag is of type NUMBER';
PBK_TXT_110	constant varchar2(200)		:= 'Tag is of type DATE';

PBK_TXT_111	constant varchar2(200)		:= 'Tag is of type TIME';
PBK_TXT_112	constant varchar2(200)		:= 'Tag is a List of Values';
PBK_TXT_113	constant varchar2(200)		:= 'Tag is of type INTEGER';
PBK_TXT_114	constant varchar2(200)		:= 'Gallery Pricing';
PBK_TXT_115	constant varchar2(200)		:= 'Loaded';
PBK_TXT_116	constant varchar2(200)		:= 'Modified';
PBK_TXT_117	constant varchar2(200)		:= 'Delete all Original Images';
PBK_TXT_118	constant varchar2(200)		:= 'Delete all Backups';
PBK_TXT_119	constant varchar2(200)		:= 'Delete all Links';
PBK_TXT_120	constant varchar2(200)		:= 'Before you can configure preferences a Price Book must first be created';

PBK_TXT_121	constant varchar2(200)		:= 'Click Here to Create a Price Book';
PBK_TXT_122	constant varchar2(200)		:= 'For the Ordering to work, a Price Book must be attached to the Order Style';
PBK_TXT_123	constant varchar2(200)		:= 'Price Book Problem. There are Film Types that do not match the ones in the Price Book. There will be ordering problems.';
PBK_TXT_124	constant varchar2(200)		:= 'The following Film Types are Problem ones';
PBK_TXT_125	constant varchar2(200)		:= 'To Create a New Order you will need to Logout and Log back in again';
PBK_TXT_126	constant varchar2(200)		:= 'Password has Expired. Please enter in a new one';
PBK_TXT_127	constant varchar2(200)		:= 'Change FTP Locations';
PBK_TXT_128	constant varchar2(200)		:= 'Download';
PBK_TXT_129	constant varchar2(200)		:= 'The following Account has now been completely deleted and cannot be recovered';
PBK_TXT_130	constant varchar2(200)		:= 'The following Accounts have been marked for Deletion. Click on the Account to Restore it.';

PBK_TXT_131	constant varchar2(200)		:= 'Client Discounts';
PBK_TXT_132	constant varchar2(200)		:= 'Modify Client Discounts';
PBK_TXT_133	constant varchar2(200)		:= 'Client Discounts successfully modified';

--
-- GCARD
--

GCARD_TXT_001	constant varchar2(200)		:= 'Create a Greeting Card';
GCARD_TXT_002	constant varchar2(200)		:= 'Current Shape';
GCARD_TXT_003	constant varchar2(200)		:= ' Change Card Shape to :';
GCARD_TXT_004	constant varchar2(200)		:= 'Your Name';
GCARD_TXT_007	constant varchar2(200)		:= 'Send To Email';
GCARD_TXT_008	constant varchar2(200)		:= 'Style';
GCARD_TXT_009	constant varchar2(200)		:= 'Border';
GCARD_TXT_010	constant varchar2(200)		:= 'Greeting';

GCARD_BUT_011	constant varchar2(200)		:= 'Create Card';
GCARD_TXT_012	constant varchar2(200)		:= 'Also Send to';

GCARD_TXT_025	constant varchar2(200)		:= 'Card Expires at Date';
GCARD_TXT_026	constant varchar2(200)		:= 'Card Editing Cancelled';
GCARD_TXT_027	constant varchar2(200)		:= 'You must specify your name and email address';
GCARD_TXT_028	constant varchar2(200)		:= 'You must specify a name and an email address to send this greeting card to';
GCARD_TXT_029	constant varchar2(200)		:= 'Card Created';
GCARD_TXT_020	constant varchar2(200)		:= 'Card Successfully Edited';

GCARD_TXT_031	constant varchar2(200)		:= 'Greeting Card Options';
GCARD_TXT_032	constant varchar2(200)		:= 'Electronic Greeting Card has been cancelled';
GCARD_TXT_033	constant varchar2(200)		:= 'Electronic Greeting Card has been Deleted';
GCARD_TXT_034	constant varchar2(200)		:= 'You have received an Electronic Greeting Card';
GCARD_TXT_035	constant varchar2(200)		:= 'Electronic Greeting Card has been sent to: ';
GCARD_TXT_036	constant varchar2(200)		:= 'Invalid Greeting Card';
GCARD_TXT_037	constant varchar2(200)		:= 'This Greeting Card has Expired';
GCARD_TXT_038	constant varchar2(200)		:= 'Quota Exceeded: Maximum number of photos reached';
GCARD_TXT_039	constant varchar2(200)		:= 'Quota Exceeded: Maximum photo size exceeded';
GCARD_TXT_030	constant varchar2(200)		:= 'Quota Exceeded: Insufficient storage left to store the photo and the thumbnail';

GCARD_ALT_031	constant varchar2(200)		:= 'Photo is displayed on the left, text is displayed on the right.';
GCARD_ALT_032	constant varchar2(200)		:= 'Text is displayed on the left, Photo is displayed on the right.';
GCARD_ALT_033	constant varchar2(200)		:= 'Text is displayed above and below the Photo.';
GCARD_ALT_034	constant varchar2(200)		:= 'Text is displayed below the Photo.';
GCARD_ALT_035	constant varchar2(200)		:= 'Your Electronic Greeting Card has been viewed';
GCARD_ALT_036	constant varchar2(200)		:= 'Change Screen Size:';
GCARD_ALT_037	constant varchar2(200)		:= '* - Mandatory Field';

--
-- UMP
--

UMP_TXT_001	constant varchar2(200)		:= 'Image is too large to modify';
UMP_TXT_002	constant varchar2(200)		:= 'Problem occurred when modifying the image';
UMP_TXT_003	constant varchar2(200)		:= 'The Watermark is too big to merge it in with the Image';
UMP_TXT_004	constant varchar2(200)		:= 'Cannot find the Image';
UMP_TXT_005	constant varchar2(200)		:= 'Unable to lock image to modify it. Please try again later';
UMP_TXT_006	constant varchar2(200)		:= 'Cannot fetch the image from the database. Please try again later';
UMP_TXT_007	constant varchar2(200)		:= 'Could not insert audit record into the database';
UMP_TXT_008	constant varchar2(200)		:= 'Could not convert the image from JPEG back to Raw Pixel';
UMP_TXT_009	constant varchar2(200)		:= 'Unable to lock the image to convert it back to JPEG';
UMP_TXT_010	constant varchar2(200)		:= 'Problem occurred when converting the image back to JPEG';

UMP_TXT_011	constant varchar2(200)		:= 'Unable to convert the Image from Raw Pixel back to JPEG';
UMP_TXT_012	constant varchar2(200)		:= 'Unable to create the thumbnail';
UMP_TXT_013	constant varchar2(200)		:= 'Image is empty';
UMP_TXT_014	constant varchar2(200)		:= 'Bad Parameter Given';
UMP_TXT_015	constant varchar2(200)		:= 'Unable to write image to the directory';
UMP_TXT_016	constant varchar2(200)		:= 'File not found';
UMP_TXT_017	constant varchar2(200)		:= 'Object not found at location';
UMP_TXT_018	constant varchar2(200)		:= 'No files found in the directory';
UMP_TXT_020	constant varchar2(200)		:= 'Problem occurred when rotating the image';

UMP_TXT_021	constant varchar2(200)		:= 'Problem occurred when embedding the watermark';
UMP_TXT_024	constant varchar2(200)		:= 'Quota Exceeded. Possible cause: Upload Image is larger in size than ';
UMP_TXT_025	constant varchar2(200)		:= ' or you have exceeded your total storage allocation.';
UMP_TXT_026	constant varchar2(200)		:= 'Size of Original Photo''s (Kb)';
UMP_TXT_027	constant varchar2(200)		:= 'Total Number of Original Photo''s';
UMP_TXT_028	constant varchar2(200)		:= 'Size of Web Photo''s (Kb)';
UMP_TXT_029	constant varchar2(200)		:= 'Total Number of Web Photo''s';
UMP_TXT_030	constant varchar2(200)		:= 'Size of Backup Photo''s (Kb)';

UMP_TXT_031	constant varchar2(200)		:= 'Total Number of Backup Photo''s';
UMP_TXT_032	constant varchar2(200)		:= 'Size of Thumbnail''s (Kb)';
UMP_TXT_033	constant varchar2(200)		:= 'Total Number of Thumbnail''s';
UMP_TXT_034	constant varchar2(200)		:= 'Maximum object size exceeded. Allowed in (Kb) is';
UMP_TXT_035	constant varchar2(200)		:= 'Object size is';
UMP_TXT_036	constant varchar2(200)		:= 'Number of objects';
UMP_TXT_037	constant varchar2(200)		:= 'Maximum object total size exceeded. Allowed is';
UMP_TXT_038	constant varchar2(200)		:= 'Current total is';

--
-- FNM
--

FNM_TXT_001	constant varchar2(200)		:= 'Form Cancelled';
FNM_TXT_002	constant varchar2(200)		:= 'List all Order Forms Made';
FNM_TXT_003	constant varchar2(200)		:= 'Not Sent';
FNM_TXT_004	constant varchar2(200)		:= 'Roll';
FNM_TXT_005	constant varchar2(200)		:= 'Click on the Roll Name to Display the Order for it';
FNM_TXT_006	constant varchar2(200)		:= 'Photographic Laboratory Order Form';
FNM_TXT_007	constant varchar2(200)		:= 'Choose a Lab and then choose the Orders that have been purchased to create a Lab Order Form';
FNM_TXT_008	constant varchar2(200)		:= 'Laboratory';
FNM_TXT_009	constant varchar2(200)		:= 'Photographic / Laboratory Order Forms';
FNM_TXT_010	constant varchar2(200)		:= 'Purchase Requests';

FNM_TXT_011	constant varchar2(200)		:= 'Date Updated';
FNM_TXT_013	constant varchar2(200)		:= 'Photographer/Laboratory Comments';
FNM_TXT_014	constant varchar2(200)		:= 'The Preference for this Customer Account is for no Photo Laboratory to be used. No Form can be created.';
FNM_TXT_015	constant varchar2(200)		:= 'No Laboratory forms currently exist for this Photo Laboratory. No Form can be created.';
FNM_TXT_016	constant varchar2(200)		:= 'Action';
-- FNM_TXT_017	constant varchar2(200)		:= 'This form was created by the Photographer';
FNM_TXT_018	constant varchar2(200)		:= 'Waiting for Order to be returned from Lab';
FNM_TXT_019	constant varchar2(200)		:= 'Edit Order Form';

FNM_TXT_021	constant varchar2(200)		:= 'Archive';
FNM_TXT_023	constant varchar2(200)		:= 'Send to Laboratory Electronically';
FNM_TXT_024	constant varchar2(200)		:= 'Send to Laboratory by Courier Mail';
FNM_TXT_025	constant varchar2(200)		:= 'Cancel Form';
FNM_TXT_026	constant varchar2(200)		:= 'Laboratory has acknowledged the order';
FNM_TXT_027	constant varchar2(200)		:= 'Order Received from Laboratory';
FNM_TXT_028	constant varchar2(200)		:= 'Laboratory has processed the Order';
FNM_TXT_029	constant varchar2(200)		:= 'Laboratory has problems with the Order';
FNM_TXT_030	constant varchar2(200)		:= 'Print this Page';

FNM_BUT_032	constant varchar2(200)		:= 'Submit Form';
FNM_BUT_033	constant varchar2(200)		:= 'Add More Purchase Requests';
FNM_BUT_034	constant varchar2(200)		:= 'View Order Forms';
FNM_BUT_035	constant varchar2(200)		:= 'Create Order';
FNM_BUT_039	constant varchar2(200)		:= 'Delete all Cancelled Orders';
FNM_BUT_040	constant varchar2(200)		:= 'Display Archived Orders';

FNM_BUT_041	constant varchar2(200)		:= 'Create New Order Form';
FNM_TXT_042	constant varchar2(200)		:= 'Edit an Order Form';
FNM_TXT_043	constant varchar2(200)		:= 'The details for this order have been sent electronically to the Laboratory. You can track its progress through this system. When the Lab has completed the order you will be sent an email.';
FNM_TXT_044	constant varchar2(200)		:= 'You have marked this order as one in which you will send all the details to the Laboratory. When the order has been returned from the Lab mark it as having been received.';
FNM_TXT_045	constant varchar2(200)		:= 'This order has been marked as Archived.';
FNM_TXT_046	constant varchar2(200)		:= 'This order has been cancelled';
FNM_TXT_047	constant varchar2(200)		:= 'This order has been marked as being received from the Laboratory';
FNM_TXT_048	constant varchar2(200)		:= 'Modify Comments';
FNM_TXT_049	constant varchar2(200)		:= 'Comments has been updated';
FNM_TXT_050	constant varchar2(200)		:= 'Date Sent';

FNM_TXT_051	constant varchar2(200)		:= 'Clearance';
FNM_TXT_052	constant varchar2(200)		:= 'Manufacturer Excessive Stock Clearance';
FNM_TXT_053	constant varchar2(200)		:= 'Expiry Date';
FNM_TXT_055	constant varchar2(200)		:= 'Create a New Clearance';
FNM_TXT_056	constant varchar2(200)		:= 'Insert New Clearance';
FNM_TXT_057	constant varchar2(200)		:= 'Modify Clearance Details';
FNM_TXT_058	constant varchar2(200)		:= 'Warranty';
FNM_TXT_059	constant varchar2(200)		:= 'Warranty Name';
FNM_TXT_060	constant varchar2(200)		:= 'Warranty HTML Page';

FNM_TXT_061	constant varchar2(200)		:= 'Dump it by Date';
FNM_TXT_062	constant varchar2(200)		:= 'Detailed Description';
FNM_TXT_063	constant varchar2(200)		:= 'Clearance Details Modified';
FNM_TXT_064	constant varchar2(200)		:= 'Display Clearance List';
FNM_TXT_065	constant varchar2(200)		:= 'Photographers/Clients who can Action this Clearance';
FNM_TXT_066	constant varchar2(200)		:= 'New Clearance Request from: ';
FNM_TXT_067	constant varchar2(200)		:= 'Warranty Details Updated';
FNM_TXT_068	constant varchar2(200)		:= 'Modify Warranty Details';
FNM_TXT_070	constant varchar2(200)		:= 'Description as supplied by Manufacturer';

FNM_TXT_071	constant varchar2(200)		:= 'Display on Customer Home Page';
FNM_TXT_072	constant varchar2(200)		:= 'Email Customer';
FNM_TXT_073	constant varchar2(200)		:= 'SMS Notify Customer';
FNM_TXT_074	constant varchar2(200)		:= 'Telesales';
FNM_TXT_075	constant varchar2(200)		:= 'Manual Shipping Charge';
FNM_TXT_077	constant varchar2(200)		:= 'Price Per Unit<BR>if this Quantity Specified<BR>$999,999.99';
FNM_TXT_078	constant varchar2(200)		:= 'Price Per Unit';
FNM_TXT_079	constant varchar2(200)		:= 'Send out Email and SMS Messages now';
FNM_TXT_080	constant varchar2(200)		:= 'Mfctr Clearance';

FNM_TXT_081	constant varchar2(200)		:= 'Manufacturer Excessive<BR>Stock Clearance';
FNM_TXT_082	constant varchar2(200)		:= 'Shipping price is valid to anywhere in Australia';
FNM_TXT_083	constant varchar2(200)		:= 'Shipping price cannot be determined and is not included in this price. Will be calculated manually';
FNM_TXT_084	constant varchar2(200)		:= 'Purchase this Clearance';
FNM_TXT_085	constant varchar2(200)		:= 'Invalid Quantity Specified';
FNM_TXT_086	constant varchar2(200)		:= 'Warranty/Terms and Condition not available';
FNM_TXT_087	constant varchar2(200)		:= 'Warranty/Terms and Condition';
FNM_TXT_088	constant varchar2(200)		:= 'Attach Image';
FNM_TXT_089	constant varchar2(200)		:= 'No Image attached to this Item';
FNM_TXT_090	constant varchar2(200)		:= 'Attach Images to Price Book Items';

FNM_TXT_091	constant varchar2(200)		:= 'Attach all Images, even if they already have an image attached';
FNM_TXT_092	constant varchar2(200)		:= 'Filename matches Product Name';
FNM_TXT_093	constant varchar2(200)		:= 'Filename matches Cross Reference Code';
FNM_TXT_094	constant varchar2(200)		:= 'Use best guess to match Product to Image';
FNM_TXT_095	constant varchar2(200)		:= 'Perform Match';
FNM_TXT_096	constant varchar2(200)		:= 'Result of Match';
FNM_TXT_097	constant varchar2(200)		:= 'Image Location';
FNM_TXT_098	constant varchar2(200)		:= 'Result';
FNM_TXT_099	constant varchar2(200)		:= 'Matched';
FNM_TXT_100	constant varchar2(200)		:= 'Could not Match';

FNM_TXT_101	constant varchar2(200)		:= 'Convert this Product into a Clearance';
FNM_TXT_102	constant varchar2(200)		:= 'Delete all Comments attached to Images';
FNM_TXT_103	constant varchar2(200)		:= 'Delete all Names of People attached to Images';
FNM_TXT_105	constant varchar2(200)		:= 'Is this a Direct Shopping Item?';
FNM_TXT_107	constant varchar2(200)		:= 'To enable this item as a Direct Shopping Item, first map the Item to a Lab Item';
FNM_TXT_108	constant varchar2(200)		:= 'General Category';
FNM_TXT_109	constant varchar2(200)		:= 'Include with every Category';
FNM_TXT_110	constant varchar2(200)		:= 'No Image';

FNM_TXT_111	constant varchar2(200)		:= 'Delivery Time Details';
FNM_TXT_112	constant varchar2(200)		:= 'General Preferences (Display, Cost, Help, Tax, Quality)';
FNM_TXT_113	constant varchar2(200)		:= 'Available Payment Methods';
FNM_TXT_114	constant varchar2(200)		:= 'If International Order, Customer must choose Credit Card';
FNM_TXT_115	constant varchar2(200)		:= 'Customer can choose to Pay by Phone';
FNM_TXT_116	constant varchar2(200)		:= 'Customer can choose to Pay by Credit Card (Piction)';
FNM_TXT_117	constant varchar2(200)		:= 'Customer can choose to Pay by Credit Card (External Merchant)';
FNM_TXT_118	constant varchar2(200)		:= 'Customer can pay by Cheque/Money Order';
--FNM_TXT_119	constant varchar2(200)		:= 'On Phone Orders, Photographer contacts Customer';
--FNM_TXT_120	constant varchar2(200)		:= 'On Phone Orders, Customer contacts Photographer';

FNM_TXT_121	constant varchar2(200)		:= 'Customer can choose to Pay using Account';
FNM_TXT_122	constant varchar2(200)		:= 'To Arrange for Payment please Ring the <PHOTOGRAPHER> on';
FNM_TXT_123	constant varchar2(200)		:= 'You will need to ring the <PHOTOGRAPHER> during business hours.';
FNM_TXT_124	constant varchar2(200)		:= 'Pay by Cheque or Money Order';
FNM_TXT_125	constant varchar2(200)		:= 'Please Print this Screen and attach it with your Cheque or Money Order and forward to the following Address.';
FNM_TXT_126	constant varchar2(200)		:= 'Order Number';
FNM_TXT_127	constant varchar2(200)		:= 'Run Manufacturer Search';
FNM_TXT_128	constant varchar2(200)		:= 'Brand';
FNM_TXT_129	constant varchar2(200)		:= 'Manufacturer Search';
FNM_TXT_130	constant varchar2(200)		:= 'Price Range';

FNM_TXT_131	constant varchar2(200)		:= 'From';
FNM_TXT_132	constant varchar2(200)		:= 'To';
FNM_TXT_133	constant varchar2(200)		:= 'Manufacturer Clearance Items';
FNM_TXT_134	constant varchar2(200)		:= 'Reverse Auction Items';
FNM_TXT_135	constant varchar2(200)		:= 'In the Price Range of';
FNM_TXT_137	constant varchar2(200)		:= 'Brand name is';
FNM_TXT_138	constant varchar2(200)		:= 'Has Interest of';
FNM_TXT_139	constant varchar2(200)		:= 'Advanced Search';

FNM_TXT_141	constant varchar2(200)		:= 'e.g. *.jpg, myclient\*.jpg, photo*.jpg';
FNM_TXT_142	constant varchar2(200)		:= 'Product Image';
FNM_TXT_143	constant varchar2(200)		:= 'Shopping Store';
FNM_TXT_144	constant varchar2(200)		:= 'No Manufacturer Clearances Found';
FNM_TXT_146	constant varchar2(200)		:= 'This Order has exceeded the allowed credit limit of';
FNM_TXT_148	constant varchar2(200)		:= 'Manage <PHOTOGRAPHER> Icons';
FNM_TXT_149	constant varchar2(200)		:= 'Icon Successfully Modified';
FNM_TXT_150	constant varchar2(200)		:= 'Add a New Icon';

FNM_TXT_151	constant varchar2(200)		:= 'Address Book';
FNM_TXT_152	constant varchar2(200)		:= 'Manage Address Books';
FNM_TXT_154	constant varchar2(200)		:= 'Create a New Address Book';
FNM_TXT_155	constant varchar2(200)		:= 'Delete Address Book';
FNM_TXT_156	constant varchar2(200)		:= 'Name of Address Book';
FNM_TXT_157	constant varchar2(200)		:= 'Address Book has been deleted';
FNM_TXT_158	constant varchar2(200)		:= 'This Address Book already exists';
FNM_TXT_159	constant varchar2(200)		:= 'Manage Address Book Entries';
FNM_TXT_160	constant varchar2(200)		:= 'Modify Address Book Entries';

FNM_TXT_161	constant varchar2(200)		:= 'Address Book Entries Successfully Modified';
FNM_TXT_162	constant varchar2(200)		:= 'The Credit Card Details have not been accepted.';
FNM_TXT_163	constant varchar2(200)		:= 'This Order cannot be confirmed until the Credit Card is accepted.';
FNM_TXT_164	constant varchar2(200)		:= 'Return to the Payment Confirmation Page and Retry Payment.';
FNM_TXT_165	constant varchar2(200)		:= 'Manage Security Roles';
FNM_TXT_166	constant varchar2(200)		:= 'Role Details';
FNM_TXT_167	constant varchar2(200)		:= 'Role Details successfully Modified';
FNM_TXT_168	constant varchar2(200)		:= 'There are no reports available to be run';
FNM_TXT_169	constant varchar2(200)		:= 'Before printing please configure your printer for Landscape Mode.';
FNM_TXT_170	constant varchar2(200)		:= 'Shipping Charge';

FNM_TXT_171	constant varchar2(200)		:= 'Additional Charge';
FNM_TXT_172	constant varchar2(200)		:= 'Additional Charge Description';
FNM_TXT_173	constant varchar2(200)		:= 'Reverse Engineer Emails into Address Book';
FNM_TXT_174	constant varchar2(200)		:= 'Email Address reverse engineered';
FNM_TXT_175	constant varchar2(200)		:= 'Submit for Further Parameters';
FNM_TXT_176	constant varchar2(200)		:= 'To print this invoice please select one of the two options below.';

end lng2;

/
