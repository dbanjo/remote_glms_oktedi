CREATE OR REPLACE package WEBSYS.lng
as

--
-- English Language Module
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

-- This value is what all the currency is displayed
MONEY_FORMAT	constant varchar2(200)		:= '$999,999,990.99';
LRG_MONEY_FORMAT constant varchar2(200)		:= '$999,999,999,990.99';
-- This value is what all Date Stamps are displayed
MASK		constant varchar2(50)		:= 'DD-Mon-YYYY';
-- This value is what all Date Time Stamps are displayed
TSMASK		constant varchar2(50)		:= 'DD-Mon-YYYY HH24:MI';
TSMASK_ONLY	constant varchar2(50)		:= 'HH24:MI';
-- The home country when an order is made
--HOME_CTRY	constant varchar2(200)		:= 'AUSTRALIA';
--HOME_CURRENCY	constant varchar2(200)		:= 'AUD';
PARENT_FRM	constant varchar2(200)		:= 'Discussion Forum';

--
-- GLB
--

GLB_TXT_001	constant varchar2(200) 		:= 'Your Session has been Disconnected';
GLB_TXT_002	constant varchar2(200)		:= 'You need to enter in your username and password';
-- The values (E1),(E2),(E3) are used by us if users have trouble logging in. Do not translate them.
GLB_TXT_003	constant varchar2(200)		:= 'Invalid Username/Password (E1)';
GLB_TXT_004	constant varchar2(200)		:= 'Invalid Username/Password (E2)';
GLB_TXT_005	constant varchar2(200)		:= 'Invalid Username/Password (E3)';
GLB_TXT_006	constant varchar2(200)		:= 'This Account has Expired';
GLB_TXT_007	constant varchar2(200)		:= 'Expiry date was';
GLB_TXT_008	constant varchar2(200)		:= 'Return to Login Page';
GLB_TXT_009	constant varchar2(200)		:= 'Press here if you would like to reopen your account';
GLB_TXT_010	constant varchar2(200)		:= 'Cookie was not found. Check to make sure you have cookies enabled.';

GLB_TXT_011	constant varchar2(200)		:= 'Session has been Disconnected either by the Administrator or because the session timed out';
GLB_TXT_012	constant varchar2(200)		:= 'Session has timed out. If your session is inactive for ';
GLB_TXT_013	constant varchar2(200)		:= ' minutes, it is disconnected.';
GLB_TXT_014	constant varchar2(200)		:= 'To Login Again Please Enter in your Account Name and Password';
GLB_TXT_015	constant varchar2(200)		:= 'Please Enter in your Connection Details';
GLB_TXT_016	constant varchar2(200)		:= 'Please enter in your username and password';
GLB_TXT_017	constant varchar2(200)		:= 'Account';
GLB_TXT_018	constant varchar2(200)		:= 'Password';
GLB_TXT_019	constant varchar2(200)		:= 'Login';
GLB_TXT_020	constant varchar2(200)		:= 'Login Error';

GLB_TXT_021	constant varchar2(200) 		:= 'Account Deletion Cancelled';
GLB_TXT_022	constant varchar2(200)		:= 'Please Confirm that you want to Delete this Account';
GLB_TXT_023	constant varchar2(200)		:= 'Once Deleted, the account is kept for one week before being completely deleted.';
GLB_TXT_024	constant varchar2(200)		:= 'You have to enter in a username';
GLB_TXT_025	constant varchar2(200)		:= 'You have to enter in an account name';
GLB_TXT_026	constant varchar2(200)		:= 'You have to enter in a password for the user';
GLB_TXT_027	constant varchar2(200)		:= 'This Username already exists. Please select one which does not exist: ';
GLB_TXT_028	constant varchar2(200)		:= 'The owner password and the customer password for this account cannot be the same.';
GLB_TXT_029	constant varchar2(200)		:= 'This Browser does not support Frames';

GLB_TXT_030	constant varchar2(200)		:= 'Account Modified Successfully';
GLB_TXT_032	constant varchar2(200)		:= 'Click to Return';
GLB_TXT_033	constant varchar2(200)		:= '[Close Window]';
GLB_TXT_035	constant varchar2(200)		:= 'An Error Has Occurred';
GLB_TXT_036	constant varchar2(200)		:= 'We apologise for this error. The details have been logged and a computer expert will look at it as soon as possible.';
GLB_TXT_037	constant varchar2(200)		:= 'Please press your BACK Button to continue working and try another function.';
GLB_TXT_038	constant varchar2(200)		:= 'Debug Information';
GLB_TXT_039	constant varchar2(200)		:= 'Error cannot be trapped:';
GLB_TXT_040	constant varchar2(200)		:= 'Please note down the error and report/email to the Support Centre';

GLB_BUT_041	constant varchar2(200)		:= 'Do Not Delete this Account';
GLB_BUT_042	constant varchar2(200)		:= 'Delete this Account';
GLB_TXT_045	constant varchar2(200)		:= 'Audio File Deleted';
GLB_TXT_046	constant varchar2(200)		:= 'Audio File Successfully Loaded';
GLB_TXT_047	constant varchar2(200)		:= 'Screen Size is currently set to SVGA (800x600)';
GLB_TXT_048	constant varchar2(200)		:= 'Click to Change Screen Size to SVGA (800x600)';
GLB_TXT_049	constant varchar2(200)		:= 'Screen Size is currently set to XGA (1024x768)';
GLB_TXT_050	constant varchar2(200)		:= 'Click to Change Screen Size to XGA (1024x768)';

GLB_TXT_051	constant varchar2(200)		:= 'Screen Size is currently set to larger than XGA (1400x1050)';
GLB_TXT_052	constant varchar2(200)		:= 'Click to Change Screen Size to a large screen size (1400x1050)';
GLB_TXT_053	constant varchar2(200)		:= 'This Account is not yet ready to be Accessed';
GLB_TXT_054	constant varchar2(200)		:= 'Message: ';
GLB_TXT_055	constant varchar2(200)		:= 'Enabled';
GLB_TXT_056	constant varchar2(200)		:= ' Disabled';
GLB_TXT_059	constant varchar2(200)		:= 'Message if Disabled';
GLB_TXT_060	constant varchar2(200)		:= 'Modify';

GLB_ALT_061	constant varchar2(200)		:= 'List all Audio Messages';
GLB_TXT_062	constant varchar2(200)		:= 'Listing of all Audio Files';
GLB_TXT_063	constant varchar2(200)		:= 'Order';
GLB_TXT_064	constant varchar2(200)		:= 'Thumbnail';
GLB_TXT_065	constant varchar2(200)		:= 'Audio';
GLB_TXT_066	constant varchar2(200)		:= 'Details';
GLB_TXT_067	constant varchar2(200)		:= 'File Size :';
GLB_TXT_068	constant varchar2(200)		:= 'File Type :';

GLB_TXT_070	constant varchar2(200)		:= 'Problems Listening to Audio Message? - Not all Sites and Browsers Support Audio (Netscape has known issues with Audio).';
GLB_ALT_071	constant varchar2(200)		:= 'Display detailed help on how to use this screen';
GLB_TXT_072	constant varchar2(200)		:= 'Expand';
GLB_TXT_073	constant varchar2(200)		:= 'Manage Comic Accounts';
GLB_TXT_074	constant varchar2(200)		:= 'Create New Account';
GLB_TXT_076	constant varchar2(200)		:= 'Username';
GLB_TXT_077	constant varchar2(200)		:= 'Account Disabled';
GLB_TXT_078	constant varchar2(200)		:= 'Date Created';
GLB_TXT_079	constant varchar2(200)		:= 'Minimise';
GLB_TXT_080	constant varchar2(200)		:= 'Available Audio Photographs';

GLB_TXT_081	constant varchar2(200)		:=  'Enter in your email address if you would like to be notified when the account is available';
GLB_TXT_082	constant varchar2(200)		:=  'Save Email Address';
GLB_TXT_083	constant varchar2(200)		:=  'Your email address has been saved.';
GLB_TXT_084	constant varchar2(200)		:=  'When this account is enabled, then an email will be sent to you.';
GLB_TXT_086	constant varchar2(200)		:=  'Standard';
GLB_TXT_089	constant varchar2(200)		:=  'Email Message sent to';

GLB_TXT_090	constant varchar2(200)		:=  'Message from ';
GLB_TXT_091	constant varchar2(200)		:=  'Index';
GLB_TXT_092	constant varchar2(200)		:=  'Search';
GLB_TXT_093	constant varchar2(200)		:=  'Contents';
GLB_TXT_094	constant varchar2(200)		:=  'This Help Topic has not been built yet';
GLB_TXT_095	constant varchar2(200)		:=  'Create New Comic Account';
GLB_TXT_096	constant varchar2(200)		:=  'Update Comic Account';
GLB_TXT_097	constant varchar2(200)		:=  'This Username already exists. Please try another one';
GLB_TXT_098	constant varchar2(200)		:=  'The password cannot be empty. Please type in a password';

GLB_TXT_100	constant varchar2(200)		:=  'Search Results';
GLB_TXT_101	constant varchar2(200)		:=  'Search Keyword (one word only)';
GLB_TXT_102	constant varchar2(200)		:=  'Results of Search for: ';
GLB_TXT_103	constant varchar2(200)		:=  'No Results where found from the search. Please try again.';
GLB_TXT_104	constant varchar2(200)		:=  'Right Click has been disabled for this Image.';
GLB_TXT_105	constant varchar2(200)		:=  'Confirm New Password';
GLB_TXT_106	constant varchar2(200)		:=  'New Password and Confirmed Password do not match';
GLB_TXT_107	constant varchar2(200)		:=  'ABN';
GLB_TXT_108	constant varchar2(200)		:=  'Please contact your <PHOTOGRAPHER>';
GLB_TXT_109	constant varchar2(200)		:=  'Extend the Life of an Account';
GLB_TXT_110	constant varchar2(200)		:=  'Enter in your email address and phone number below and the <PHOTOGRAPHER> will contact you to discuss extending this account.';

GLB_TXT_111	constant varchar2(200)		:=  'Confirm Request';
GLB_TXT_112	constant varchar2(200)		:=  'Your Request has been sent to';
GLB_TXT_113	constant varchar2(200)		:=  'Thankyou';
GLB_TXT_114	constant varchar2(200)		:=  'Request Customer Account Extension';
GLB_TXT_115	constant varchar2(200)		:=  'Help';
GLB_TXT_116	constant varchar2(200)		:=  'New Password';
GLB_TXT_117	constant varchar2(200)		:=  'Current Password';
GLB_TXT_118	constant varchar2(200)		:=  'Your Old Password does not match. Please re-enter in a valid password.';
GLB_TXT_119	constant varchar2(200)		:=  'You must enter in values for all fields.';
GLB_TXT_120	constant varchar2(200)		:=  'Your new password and confirmed new password do not match. Please re-enter in valid passwords.';

GLB_TXT_121	constant varchar2(200)		:=  'Password Modified';
GLB_TXT_122	constant varchar2(200)		:=  'record in the table not found.';
GLB_TXT_123	constant varchar2(200)		:=  'Edit';
GLB_TXT_124	constant varchar2(200)		:=  'Page #';
GLB_TXT_125	constant varchar2(200)		:=  'Group';
GLB_TXT_126	constant varchar2(200)		:=  'Photo Gallery';
GLB_TXT_127	constant varchar2(200)		:=  'Audio Greeting';
GLB_TXT_128	constant varchar2(200)		:=  'Video Greeting';
GLB_TXT_129	constant varchar2(200)		:=  'Document Greeting';

GLB_TXT_131	constant varchar2(200)		:=  'This image is currently not available to be ordered.';
GLB_TXT_132	constant varchar2(200)		:=  'Ordering Details';
GLB_TXT_133	constant varchar2(200)		:=  'You must provide an email address to login';
GLB_TXT_135	constant varchar2(200)		:=  'Choose Category from List';
GLB_TXT_136	constant varchar2(200)		:=  'Not Specified';

--
-- CST
--

CST_TXT_004	constant varchar2(200)		:= 'Business Name';
CST_TXT_005	constant varchar2(200)		:= 'Contact Details';
CST_TXT_006	constant varchar2(200)		:= 'Address';
CST_TXT_007	constant varchar2(200)		:= 'Not Supplied';
CST_TXT_008	constant varchar2(200)		:= 'Work Number';
CST_TXT_009	constant varchar2(200)		:= 'Mobile';
CST_TXT_010	constant varchar2(200)		:= 'Change was Successful';

CST_TXT_011	constant varchar2(200)		:= 'Modify values and the press SAVE. To abandon changes press CANCEL. To ignore a value just empty the field.';
CST_TXT_012	constant varchar2(200)		:= 'Meta Tags';
CST_TXT_013	constant varchar2(200)		:= 'Value';
CST_TXT_014	constant varchar2(200)		:= 'Return to Details Screen';
CST_BUT_016	constant varchar2(200)		:= 'Cancel';
CST_BUT_017	constant varchar2(200)		:= 'Save Changes';
CST_BUT_018	constant varchar2(200)		:= 'Save Changes and Return';
CST_TXT_019	constant varchar2(200)		:= 'Click to view images';

CST_ALT_021	constant varchar2(200)		:= 'Logoff';
CST_ALT_022	constant varchar2(200)		:= 'How do I use this?';
CST_ALT_023	constant varchar2(200)		:= 'Edit Details for';
CST_ALT_024	constant varchar2(200)		:= 'This Image has been marked by the <PHOTOGRAPHER> as being a Special Moment';
CST_ALT_025	constant varchar2(200)		:= 'Add this Image to your Shopping Trolley';
CST_ALT_026	constant varchar2(200)		:= 'Turn this Image into a Greeting Card and Send it to someone';
CST_ALT_027	constant varchar2(200)		:= 'Add an Audio Greeting to this Image';
CST_ALT_028	constant varchar2(200)		:= 'Return to the Category';
CST_ALT_029	constant varchar2(200)		:= 'Identify People in the Image';

CST_TXT_031	constant varchar2(200) 		:= 'Customer Account';
CST_TXT_032	constant varchar2(200)		:= 'Date of Event';
CST_TXT_033	constant varchar2(200)		:= 'Date Account Expires';
CST_TXT_034	constant varchar2(200)		:= 'Categories and #Images';
CST_TXT_035	constant varchar2(200)		:= 'Choose a Category to view the Images';
CST_TXT_036	constant varchar2(200)		:= 'Search for an Image';
CST_TXT_037	constant varchar2(200)		:= 'How to do a Search: ';
CST_TXT_038	constant varchar2(200)		:= 'Keyword';
CST_TXT_039	constant varchar2(200)		:= 'Look for a Photograph title, people in an Image or Comments in Images';

CST_TXT_042	constant varchar2(200)		:= 'Category';
CST_TXT_043	constant varchar2(200)		:= 'Search for Images that belong to a Category';
CST_TXT_045	constant varchar2(200)		:= 'View Images';
CST_TXT_050	constant varchar2(200)		:= 'Who is in the Image';

CST_TXT_051	constant varchar2(200)		:= 'Comments';
CST_TXT_052	constant varchar2(200)		:= 'Album<BR>Image';
CST_TXT_053	constant varchar2(200)		:= 'Image<BR>Enabled';
CST_TXT_054	constant varchar2(200)		:= '[More Comments...]';
CST_TXT_055	constant varchar2(200)		:= 'Add a Comment';
CST_TXT_056	constant varchar2(200)		:= 'Please Check a Checkbox to Select Images to Order or Display.';
CST_TXT_057	constant varchar2(200)		:= 'Press either the Browser BACK button or the button below to return to the previous screen.';
CST_TXT_058	constant varchar2(200)		:= 'Go Back to Previous Screen';
CST_TXT_059	constant varchar2(200)		:= 'Display Chosen Images';

CST_TXT_061	constant varchar2(200)		:= 'Add Name(s)';
CST_TXT_063	constant varchar2(200)		:= 'Return to Image Display';
CST_TXT_064	constant varchar2(200)		:= 'Add Images to Shopping Trolley';
CST_TXT_065	constant varchar2(200)		:= 'Add to Shopping Trolley';
CST_TXT_066	constant varchar2(200)		:= 'Who is in the Image: ';
CST_TXT_068	constant varchar2(200)		:= 'Add a name to the Image';

CST_TXT_070	constant varchar2(200)		:= 'If you have any problems then please ring';
CST_TXT_071	constant varchar2(200)		:= 'Your Purchase Request Number is';
CST_TXT_072	constant varchar2(200)		:= 'Zoom in and view closeups of the Image';

CST_TXT_081	constant varchar2(200)		:= 'You must enter in a Contact Name for the Shipping Address.';
CST_TXT_082	constant varchar2(200)		:= 'You must enter in a Street Name for the Shipping Address.';
CST_TXT_083	constant varchar2(200)		:= 'You must enter in a Suburb for the Shipping Address.';
CST_TXT_084	constant varchar2(200)		:= 'You must enter in a City for the Shipping Address.';
CST_TXT_085	constant varchar2(200)		:= 'You must enter in a Country for the Shipping Address.';
CST_ALT_086	constant varchar2(200)		:= 'Listen to Audio Message';
CST_TXT_093	constant varchar2(200)		:= 'Current Local Time is : ';
CST_TXT_094	constant varchar2(200)		:= 'We are sorry but this time is outside of our office hours.';
CST_TXT_095	constant varchar2(200)		:= 'You will be contacted during the next business day to discuss payment details.';
CST_TXT_096	constant varchar2(200)		:= 'You must enter in a Postal or Zip Code for the Shipping Address.';
CST_TXT_097	constant varchar2(200)		:= 'You must provide at least one phone number before this Purchase Request can be confirmed.';
CST_TXT_098	constant varchar2(200)		:= 'Purchase Request Confirmed.';
CST_TXT_099	constant varchar2(200)		:= 'Purchase Request #';
CST_TXT_100	constant varchar2(200)		:= ' has been confirmed.';

CST_TXT_102	constant varchar2(200)		:= 'Now that the order is confirmed the <PHOTOGRAPHER> will contact you shortly to discuss payment details.';
CST_TXT_103	constant varchar2(200)		:= 'Total Order Cost';
CST_TXT_104	constant varchar2(200)		:= 'Payment is to be made by Phone.';
CST_TXT_107	constant varchar2(200)		:= 'Please provide a list of phone numbers and any special instructions you have for being contacted.';
CST_TXT_108	constant varchar2(200)		:= 'Phone Number';
CST_TXT_109	constant varchar2(200)		:= 'Any Special Contact Instructions';

CST_TXT_112	constant varchar2(200)		:= 'Name of Person Sending To';
CST_TXT_113	constant varchar2(200)		:= 'Street';
CST_TXT_114	constant varchar2(200)		:= 'Suburb';
CST_TXT_115	constant varchar2(200)		:= 'City';
CST_TXT_116	constant varchar2(200)		:= 'Country';
CST_TXT_118	constant varchar2(200)		:= 'Post/Zip Code';
CST_TXT_120	constant varchar2(200)		:= 'Is this a Gift?';

CST_TXT_121	constant varchar2(200)		:= 'Do you want the gift wrapped?';
CST_TXT_122	constant varchar2(200)		:= 'Please Enter in a Message for the Card';
CST_TXT_123	constant varchar2(200)		:= 'Current Shopping Basket';
CST_TXT_124	constant varchar2(200)		:= 'How to Shop: ';
CST_TXT_125	constant varchar2(200)		:= 'Remove from<BR>Shopping Basket';
CST_BUT_126	constant varchar2(200)		:= 'Recalculate Order';
CST_BUT_127	constant varchar2(200)		:= 'Checkout';
CST_BUT_128	constant varchar2(200)		:= 'Add Name(s) to the Image';
CST_BUT_129	constant varchar2(200)		:= 'Return to Listing of Images';
CST_BUT_130	constant varchar2(200)		:= 'Save and Return to Images';

CST_TXT_132	constant varchar2(200)		:= 'Image Name';
CST_TXT_133	constant varchar2(200)		:= 'Add a Name';
CST_TXT_135	constant varchar2(200)		:= 'Qty';
CST_TXT_136	constant varchar2(200)		:= 'Sub Total';
CST_TXT_137	constant varchar2(200)		:= 'There are no items in the Shopping Basket';
CST_TXT_138	constant varchar2(200)		:= 'Total';
CST_TXT_139	constant varchar2(200)		:= 'Fast Checkout';
CST_TXT_140	constant varchar2(200)		:= '[Delete]';

CST_TXT_141	constant varchar2(200)		:= 'Add Comments to the Image';
CST_TXT_142	constant varchar2(200)		:= 'Made by';
CST_TXT_143	constant varchar2(200)		:= 'Your Email Address';
CST_TXT_144	constant varchar2(200)		:= 'Comment';
CST_BUT_146	constant varchar2(200)		:= 'Add Comment to the Image';
CST_BUT_149	constant varchar2(200)		:= 'Replace Audio File';
CST_BUT_150	constant varchar2(200)		:= 'Delete Audio File';

CST_TXT_152	constant varchar2(200)		:= 'You are allowed to attach an Audio Greeting to this Image. The audio file must be of type WAVE or MP3.';
CST_TXT_153	constant varchar2(200)		:= 'It is recommended that you create MP3 files as they compress better than WAV files. Try and keep the file size to under 100Kb.';
CST_TXT_154	constant varchar2(200)		:= 'Audio File already exists for this Image.';
CST_TXT_155	constant varchar2(200)		:= 'Click on image to listen to the audio file.';
CST_TXT_156	constant varchar2(200)		:= 'No Audio File Exists for this Image';
CST_TXT_157	constant varchar2(200)		:= 'Number of Audio Files';
CST_TXT_158	constant varchar2(200)		:= 'File Storage Remaining';
CST_TXT_159	constant varchar2(200)		:= 'Audio File (.wav, .mp3 or .aif)';
CST_TXT_160	constant varchar2(200)		:= 'Title for Audio Message';

CST_BUT_161	constant varchar2(200)		:= 'Load Audio File';
CST_TXT_163	constant varchar2(200)		:= 'Please Enter in your Email Address and/or Country';


CST_TXT_180	constant varchar2(200)		:= 'Purchase Request Made:';

CST_TXT_183	constant varchar2(200)		:= 'You are currently seeing smaller versions (thumbnails) of the Photograph. To see the full size version just click on the Photograph.';
CST_TXT_187	constant varchar2(200)		:= 'Choose<BR>Image';

CST_TXT_201	constant varchar2(200)		:= 'Choose Image';
CST_TXT_202	constant varchar2(200)		:= 'Album Image';
CST_TXT_203	constant varchar2(200)		:= 'Display Image';
CST_TXT_207	constant varchar2(200)		:= 'Audio Message';
CST_TXT_208	constant varchar2(200)		:= 'Personal Image Load';
CST_TXT_209	constant varchar2(200)		:= 'Current Usage';

CST_TXT_211	constant varchar2(200)		:= 'Size in Kb';
CST_TXT_212	constant varchar2(200)		:= '# in Category';
CST_TXT_215	constant varchar2(200)		:= 'Video';
CST_TXT_216	constant varchar2(200)		:= 'Document';
CST_TXT_217	constant varchar2(200)		:= 'Load into : ';
CST_TXT_218	constant varchar2(200)		:= 'Name of Object';
CST_TXT_219	constant varchar2(200)		:= 'Object Location';


CST_TXT_220	constant varchar2(200)		:= '<PHOTOGRAPHER> Gallery';
CST_TXT_221	constant varchar2(200)		:= 'Click on a Image to view it full size, or click on the order button to purchase it (where available)';
CST_TXT_225	constant varchar2(200)		:= 'Gallery';


CST_TXT_232	constant varchar2(200)		:= 'The following guests have supplied their email address' ;
CST_TXT_233	constant varchar2(200)		:= 'Notify guests account is now<BR>enabled and include this message';
CST_TXT_234	constant varchar2(200)		:= 'Send Email to all Guests';
CST_TXT_235	constant varchar2(200)		:= 'Account Look and Feel';
CST_TXT_236	constant varchar2(200)		:= 'Customer Information';

--
-- PHG
--

PHG_TXT_001	constant varchar2(200)		:= 'This account currently has no expiry date';
PHG_TXT_002	constant varchar2(200)		:= 'Next Renewal Reminder to be sent at date';
PHG_TXT_003	constant varchar2(200)		:= 'You have reached your limit of ';
PHG_TXT_005	constant varchar2(200)		:= 'Maximum number of Customer<BR>Accounts Reached: ';
PHG_TXT_006	constant varchar2(200)		:= 'Photographer';
PHG_TXT_007	constant varchar2(200)		:= 'Bad Number Entered: ';
PHG_TXT_008	constant varchar2(200)		:= ' default used.';
PHG_TXT_009	constant varchar2(200)		:= 'Preferences Successfully Modified';
PHG_TXT_010	constant varchar2(200)		:= 'Preferences';

PHG_TXT_011	constant varchar2(200)		:= 'Photo Fast Edit Mass Rotate and Watermark';
PHG_TXT_012	constant varchar2(200)		:= 'Check Images and Data Integrity';
PHG_TXT_013	constant varchar2(200)		:= 'Does not exist';
PHG_TXT_014	constant varchar2(200)		:= '<PHOTOGRAPHER> Logo';
PHG_TXT_015	constant varchar2(200)		:= 'Background Image';
PHG_TXT_016	constant varchar2(200)		:= 'Recreate Thumbnails';
PHG_TXT_017	constant varchar2(200)		:= 'Add or Modify Image';
PHG_TXT_018	constant varchar2(200)		:= 'To add or replace use the browse button to locate a GIF file containing the image.';
PHG_TXT_019	constant varchar2(200)		:= 'Image Does Not Exist';
PHG_TXT_020	constant varchar2(200)		:= 'Height';

PHG_TXT_021	constant varchar2(200)		:= 'Width';
PHG_TXT_022	constant varchar2(200)		:= 'Name';
PHG_TXT_024	constant varchar2(200)		:= 'Image Type';
PHG_TXT_025	constant varchar2(200)		:= 'Size';
PHG_TXT_026	constant varchar2(200)		:= 'Add or Change Details';
PHG_TXT_027	constant varchar2(200)		:= 'Management Completed';
PHG_TXT_028	constant varchar2(200)		:= 'Return to Preference Menu';

PHG_TXT_038	constant varchar2(200)		:= 'Background Image Successfully Loaded';
PHG_TXT_039	constant varchar2(200)		:= 'Image Successfully Loaded';
PHG_TXT_040	constant varchar2(200)		:= 'Customer Pricing';

PHG_TXT_041	constant varchar2(200)		:= 'Use this page to identify which Price Book a customer should use.';
PHG_TXT_042	constant varchar2(200)		:= 'Default';
PHG_TXT_043	constant varchar2(200)		:= 'Image Valid';
PHG_TXT_044	constant varchar2(200)		:= 'Image Invalid';
PHG_TXT_045	constant varchar2(200)		:= 'Yes';
PHG_TXT_046	constant varchar2(200)		:= 'No';
PHG_TXT_047	constant varchar2(200)		:= 'Modify Customer Price Book Details';
PHG_TXT_048	constant varchar2(200)		:= 'Image ID';
PHG_TXT_049	constant varchar2(200)		:= 'Original';
PHG_TXT_050	constant varchar2(200)		:= 'Web';

PHG_TXT_051	constant varchar2(200)		:= 'Image Fixed';
PHG_TXT_052	constant varchar2(200)		:= 'Return to Utilities Menu';
PHG_TXT_053	constant varchar2(200)		:= 'Note: Once restored, the images cannot be returned back to their old state.';
PHG_TXT_054	constant varchar2(200)		:= 'Type in the word RESTORE in upper case, to restore all the images to their original state.';
PHG_TXT_055	constant varchar2(200)		:= 'Last Query';
PHG_TXT_056	constant varchar2(200)		:= 'The following images were restored from a backup.';
PHG_TXT_057	constant varchar2(200)		:= 'The word RESTORE was not entered. Backup not performed.';
PHG_TXT_058	constant varchar2(200)		:= 'No Images found that can be restored.';

PHG_TXT_063	constant varchar2(200)		:= 'These Items are included as part of the first order';
PHG_TXT_064	constant varchar2(200)		:= 'Initial Orders';
PHG_TXT_066	constant varchar2(200)		:= 'Insert New Profile';
PHG_TXT_067	constant varchar2(200)		:= 'Enable Categories';
PHG_TXT_068	constant varchar2(200)		:= 'All Categories cannot be viewed except for the following ones';
PHG_TXT_069	constant varchar2(200)		:= 'Manage Categories';
PHG_TXT_070	constant varchar2(200)		:= 'Modify List of Categories';

PHG_TXT_071	constant varchar2(200)		:= 'Customer Profile Categories Modified';
PHG_TXT_072	constant varchar2(200)		:= 'Image Alteration Management Completed';
PHG_TXT_073	constant varchar2(200)		:= 'Modify Initial Order';
PHG_TXT_074	constant varchar2(200)		:= 'Initial Order Details Modified';
PHG_TXT_075	constant varchar2(200)		:= 'Restore all Images from Backup';
PHG_TXT_077	constant varchar2(200)		:= 'Modify Preferences';
PHG_TXT_079	constant varchar2(200)		:= 'Orders Received';
PHG_TXT_080	constant varchar2(200)		:= 'Click on the Purchase Request Number to view and modify Purchase Request details';

PHG_TXT_081	constant varchar2(200)		:= 'Order #';
PHG_TXT_082	constant varchar2(200)		:= 'Status';
PHG_TXT_083	constant varchar2(200)		:= 'Date Purchased';
PHG_TXT_084	constant varchar2(200)		:= 'Send To Name';
PHG_TXT_085	constant varchar2(200)		:= 'Order Total';
PHG_TXT_086	constant varchar2(200)		:= 'Purchase Request Details: ';
PHG_TXT_087	constant varchar2(200)		:= 'Modify Purchase Request Details';
PHG_TXT_088	constant varchar2(200)		:= 'Create New Customer Profile';
PHG_TXT_089	constant varchar2(200)		:= 'Customer Profiles';
PHG_TXT_090	constant varchar2(200)		:= 'Modify Profile';

PHG_TXT_092	constant varchar2(200)		:= 'Manage Profiles';
PHG_TXT_093	constant varchar2(200)		:= 'Order Status';
PHG_TXT_094	constant varchar2(200)		:= 'Purchase Request Number';
PHG_TXT_095	constant varchar2(200)		:= 'Total Cost';
PHG_TXT_096	constant varchar2(200)		:= 'Phone Contact Details';
PHG_TXT_097	constant varchar2(200)		:= 'Phone Number / Extra Contact Details';
PHG_TXT_100	constant varchar2(200)		:= 'Number and Street';

PHG_TXT_101	constant varchar2(200)		:= 'Send To Suburb';
PHG_TXT_102	constant varchar2(200)		:= 'Send To City';
PHG_TXT_103	constant varchar2(200)		:= 'Send To Country';
PHG_TXT_104	constant varchar2(200)		:= 'Send To Post Code / Zip' ;
PHG_TXT_105	constant varchar2(200)		:= 'Gift Details';
PHG_TXT_107	constant varchar2(200)		:= 'Should the Gift be Wrapped?';
PHG_TXT_108	constant varchar2(200)		:= 'Message on Card';

PHG_BUT_111	constant varchar2(200)		:= 'Modify Purchase Request';
PHG_BUT_112	constant varchar2(200)		:= 'List Orders';
PHG_BUT_114	constant varchar2(200)		:= 'Modify Account';
PHG_BUT_116	constant varchar2(200)		:= 'Modify Image Details';
PHG_BUT_117	constant varchar2(200)		:= 'Delete Image';
PHG_BUT_118	constant varchar2(200)		:= 'Display Category';
PHG_BUT_119	constant varchar2(200)		:= 'Delete Order';

PHG_ALT_121	constant varchar2(200)		:= 'Accounts';
PHG_TXT_122	constant varchar2(200)		:= 'Extra Information';
PHG_TXT_123	constant varchar2(200)		:= 'No Details found which can be edited';
PHG_ALT_127	constant varchar2(200)		:= 'Statistics';
PHG_ALT_128	constant varchar2(200)		:= 'Orders';
PHG_TXT_129	constant varchar2(200)		:= 'Business Feature';

PHG_ALT_133	constant varchar2(200)		:= 'Date Fulfilled';
-- PHG_ALT_134	constant varchar2(200)		:= 'Photographer Home Page for this Customer';
PHG_ALT_135	constant varchar2(200)		:= 'Logon as Customer';
PHG_ALT_136	constant varchar2(200)		:= 'Reload and Replace Current Photograph';
PHG_ALT_137	constant varchar2(200)		:= 'Convert Photo to a different format type';
PHG_ALT_138	constant varchar2(200)		:= 'Change the Compression Ratio of the JPEG';
PHG_ALT_139	constant varchar2(200)		:= 'Scale the Photo Down in Size';
PHG_ALT_140	constant varchar2(200)		:= 'Account Details';

PHG_TXT_151	constant varchar2(200)		:= 'Remove';
PHG_TXT_153	constant varchar2(200)		:= 'Photo Name';
PHG_TXT_156	constant varchar2(200)		:= 'Size: ';

PHG_TXT_161	constant varchar2(200)		:= 'Order Modified';
PHG_TXT_162	constant varchar2(200)		:= 'Enter in the Details for the New Account';
PHG_TXT_163	constant varchar2(200)		:= 'Create New Customer Account';
PHG_TXT_164	constant varchar2(200)		:= 'Account Name';
PHG_TXT_165	constant varchar2(200)		:= 'Date Event was Held';
PHG_TXT_166	constant varchar2(200)		:= 'Logon Name';
PHG_TXT_167	constant varchar2(200)		:= 'Customer Password';
PHG_TXT_168	constant varchar2(200)		:= 'Everyone else (Guest/Anonymous) Password';
PHG_TXT_169	constant varchar2(200)		:= 'Rename';

PHG_TXT_171	constant varchar2(200)		:= 'Cell Colour A';
PHG_TXT_172	constant varchar2(200)		:= 'Cell Colour B';
PHG_TXT_173	constant varchar2(200)		:= 'Reduced Image';
PHG_TXT_174	constant varchar2(200)		:= 'Account Expires';
PHG_TXT_175	constant varchar2(200)		:= 'Error Connecting. Illegal Value:';
PHG_TXT_178	constant varchar2(200)		:= 'Image Details';
PHG_TXT_180	constant varchar2(200)		:= 'Keep the File Extension';

PHG_TXT_181	constant varchar2(200)		:= 'Rename Customer Images also';
PHG_TXT_182	constant varchar2(200)		:= 'Rename Images to the Original File Name (Wildcard match)';
PHG_TXT_183	constant varchar2(200)		:= ' Add Photographs';
PHG_TXT_184	constant varchar2(200)		:= 'File';
PHG_TXT_185	constant varchar2(200)		:= 'Load Files';
PHG_TXT_186	constant varchar2(200)		:= 'Modify New Images';

PHG_TXT_193	constant varchar2(200)		:= 'Dimension: ';
PHG_TXT_194	constant varchar2(200)		:= '% or * - Wildcard match e.g. IMG* will look for any image starting with IMG';
PHG_TXT_195	constant varchar2(200)		:= 'down to width';
PHG_TXT_196	constant varchar2(200)		:= 'Photograph Proof Page';
PHG_TXT_197	constant varchar2(200)		:= 'Change Image Details';
PHG_TXT_199	constant varchar2(200)		:= 'Customer';
PHG_TXT_200	constant varchar2(200)		:= 'Category Name';

PHG_TXT_201	constant varchar2(200)		:= 'Customer can see Image<BR>Name - Roll - Mass Edit<BR>Film Type - Category Name';
PHG_TXT_202	constant varchar2(200)		:= 'Mass Edit';
PHG_TXT_203	constant varchar2(200)		:= 'down to height';
PHG_TXT_204	constant varchar2(200)		:= ' Modify Image: ';
PHG_TXT_205	constant varchar2(200)		:= 'Renamed Photo';
PHG_TXT_206	constant varchar2(200)		:= 'New Name is';
PHG_TXT_207	constant varchar2(200)		:= 'Customer can<BR>see the Image';
PHG_TXT_208	constant varchar2(200)		:= ' Standard Image';
PHG_TXT_209	constant varchar2(200)		:= 'Error modifying';
PHG_TXT_210	constant varchar2(200)		:= 'Invalid Number';

PHG_TXT_212	constant varchar2(200)		:= 'Advanced Features';
PHG_TXT_213	constant varchar2(200)		:= 'The following features should only be used by Experienced Users.';
PHG_TXT_214	constant varchar2(200)		:= 'Once Changes have been made you must reload the frames to see the image (or empty your cache).';
PHG_TXT_215	constant varchar2(200)		:= 'Reload Photograph';
PHG_TXT_216	constant varchar2(200)		:= 'Convert to Type';
PHG_TXT_217	constant varchar2(200)		:= 'Compression Quality';
PHG_TXT_218	constant varchar2(200)		:= 'Scale Down To';
PHG_TXT_219	constant varchar2(200)		:= 'Width :';
PHG_TXT_220	constant varchar2(200)		:= 'Height:';

PHG_TXT_221	constant varchar2(200)		:= 'Main Photo Statistics';
PHG_TXT_222	constant varchar2(200)		:= 'Width in Pixels';
PHG_TXT_223	constant varchar2(200)		:= 'Height in Pixels';
PHG_TXT_224	constant varchar2(200)		:= 'Size in bytes';
PHG_TXT_225	constant varchar2(200)		:= 'File Format';
PHG_TXT_226	constant varchar2(200)		:= 'Content Format';
PHG_TXT_227	constant varchar2(200)		:= 'Compression';
PHG_TXT_228	constant varchar2(200)		:= 'Mime Type';
PHG_TXT_229	constant varchar2(200)		:= 'Original Location';
PHG_TXT_230	constant varchar2(200)		:= 'Thumbnail Statistics';

PHG_TXT_231	constant varchar2(200)		:= 'Do Not Change';
PHG_TXT_232	constant varchar2(200)		:= 'Photograph Successfully Modified';
PHG_TXT_233	constant varchar2(200)		:= 'Modify Individual Details';
PHG_TXT_235	constant varchar2(200)		:= 'Business Description';
PHG_TXT_236	constant varchar2(200)		:= 'Web Site';
PHG_TXT_237	constant varchar2(200)		:= 'Work Phone';
PHG_TXT_238	constant varchar2(200)		:= 'Mobile Phone';
PHG_TXT_239	constant varchar2(200)		:= 'Contact Address - Street';
PHG_TXT_240	constant varchar2(200)		:= 'Contact Address - Suburb';

PHG_TXT_241	constant varchar2(200)		:= 'Contact Address - City';
PHG_TXT_242	constant varchar2(200)		:= 'Contact Address - Postal Code';
PHG_TXT_243	constant varchar2(200)		:= 'Date of Birth (for security checks)';
PHG_TXT_245	constant varchar2(200)		:= 'Modification was successful';
PHG_TXT_246	constant varchar2(200)		:= 'Account Statistics';
PHG_TXT_247	constant varchar2(200)		:= 'Unknown';
PHG_TXT_248	constant varchar2(200)		:= 'All Accounts';
PHG_TXT_249	constant varchar2(200)		:= 'Charge Plan';
PHG_TXT_250	constant varchar2(200)		:= 'Email Addresses';

PHG_TXT_251	constant varchar2(200)		:= 'Photograph Comments';
PHG_TXT_252	constant varchar2(200)		:= 'Greeting Cards';
PHG_TXT_253	constant varchar2(200)		:= 'Account Usage';
PHG_TXT_254	constant varchar2(200)		:= 'Account Statistics for: ';
PHG_TXT_256	constant varchar2(200)		:= 'Date Event Held';
PHG_TXT_257	constant varchar2(200)		:= 'Date Account Created';
PHG_TXT_258	constant varchar2(200)		:= 'To load a new watermark in, add the GIF containing the Watermark and press Load Watermark.';
PHG_TXT_259	constant varchar2(200)		:= 'Number of Images';
PHG_TXT_260	constant varchar2(200)		:= 'Size of Images (bytes/Kb/Mb)';

PHG_TXT_261	constant varchar2(200)		:= 'The Initial Price Book contains Private (not associated with a Lab) price items. The Lab cannot manage this Price book.';
PHG_TXT_262	constant varchar2(200)		:= 'To use this price book you must disable the ''Photo Laboratory handles all Orders'' feature';
PHG_TXT_263	constant varchar2(200)		:= 'Number of Greeting Cards';
PHG_TXT_264	constant varchar2(200)		:= 'Return to Statistics Menu';
PHG_TXT_265	constant varchar2(200)		:= 'Summary of all Customer Accounts';
PHG_TXT_266	constant varchar2(200)		:= 'The Alternative Price Book contains Private (not associated with a Lab) price items. The Lab cannot manage this Price book.';
PHG_TXT_267	constant varchar2(200)		:= 'Note: The laboratory will automatically process all orders accept ones where payment is made by phone.';
PHG_TXT_268	constant varchar2(200)		:= 'If a customer makes a phone payment then you will be sent an email containing the contact details for the customer.';
PHG_TXT_269	constant varchar2(200)		:= 'No Contact Phone Number exists for Phone Payments. You must provide a phone number if the customer experiences problems.';
PHG_TXT_270	constant varchar2(200)		:= 'Customers will ring this number if they have a problem making a Phone Payment.';

PHG_TXT_271	constant varchar2(200)		:= 'Your Account has been Disabled';
PHG_TXT_272	constant varchar2(200)		:= 'Please email the following account to have your account enabled.';
PHG_TXT_273	constant varchar2(200)		:= 'Ring the following number to have your account enabled.';
PHG_TXT_274	constant varchar2(200)		:= 'Customer Account Preferences';
PHG_TXT_275	constant varchar2(200)		:= 'can see image';
PHG_TXT_276	constant varchar2(200)		:= 'Browser Usage';
PHG_TXT_278	constant varchar2(200)		:= 'Load New Watermark';
PHG_TXT_279	constant varchar2(200)		:= 'Screen Sizes Usage';
PHG_TXT_280	constant varchar2(200)		:= 'Charge Plan Statistics';

PHG_TXT_281	constant varchar2(200)		:= 'Charge Plan Limit';
PHG_TXT_282	constant varchar2(200)		:= 'Limit';
PHG_ALT_283	constant varchar2(200)		:= 'Your Account is Due for Renewal by Date';
PHG_TXT_284	constant varchar2(200)		:= 'Remaining';
PHG_TXT_285	constant varchar2(200)		:= 'Left';
PHG_TXT_286	constant varchar2(200)		:= 'Max Storage (Kb)';
PHG_TXT_287	constant varchar2(200)		:= 'Max Customer Accounts';
PHG_TXT_288	constant varchar2(200)		:= 'Max Photographs';
PHG_ALT_289	constant varchar2(200)		:= 'Press the button to acknowledge this message';
PHG_TXT_290	constant varchar2(200)		:= 'Email Address Extracted from Photograph Comments';

PHG_ALT_291	constant varchar2(200)		:= 'Statistics for all Accounts';
PHG_ALT_292	constant varchar2(200)		:= 'Charge Plan Usage' ;
PHG_TXT_293	constant varchar2(200)		:= 'Guest Email Addresses';
PHG_ALT_295	constant varchar2(200)		:= 'Account Usage Summary';
PHG_ALT_296	constant varchar2(200)		:= 'Text';
PHG_ALT_297	constant varchar2(200)		:= 'Renewal Reminder Notice';
PHG_TXT_299	constant varchar2(200)		:= 'Email Addresses extracted from Guests';

PHG_TXT_301	constant varchar2(200)		:= 'Email Address';
PHG_TXT_302	constant varchar2(200)		:= 'Who Made It';
PHG_TXT_303	constant varchar2(200)		:= 'Comment Made';
PHG_TXT_304	constant varchar2(200)		:= 'Email Address Extracted from Greeting Cards';
PHG_TXT_305	constant varchar2(200)		:= 'From Address';
PHG_TXT_306	constant varchar2(200)		:= 'To Address';
PHG_TXT_307	constant varchar2(200)		:= 'Accessed (Y/N)';
PHG_TXT_308	constant varchar2(200)		:= 'High Quality';
PHG_TXT_309	constant varchar2(200)		:= 'Medium Quality';
PHG_TXT_310	constant varchar2(200)		:= 'Low Quality';

PHG_BUT_312	constant varchar2(200)		:= 'Comma Delimited Format';
PHG_TXT_313	constant varchar2(200)		:= 'Account Usage Summary for: ';
PHG_TXT_314	constant varchar2(200)		:= 'Total Number of Logins';
PHG_TXT_315	constant varchar2(200)		:= 'Total Page Hits';
PHG_TXT_316	constant varchar2(200)		:= 'Average Page Hits per Connection';
PHG_TXT_317	constant varchar2(200)		:= 'Screen Size';
PHG_TXT_318	constant varchar2(200)		:= 'Connections by Hour of Day';
PHG_TXT_319	constant varchar2(200)		:= 'Hour';

PHG_TXT_321	constant varchar2(200)		:= 'Number of Logins by Owner';
PHG_TXT_322	constant varchar2(200)		:= 'Number of Logins';
PHG_TXT_324	constant varchar2(200)		:= 'Thumbnail Quality Compression (1-Low 8-High)';
PHG_TXT_325	constant varchar2(200)		:= 'Thumbnail Width in Pixels';
PHG_TXT_328	constant varchar2(200)		:= 'Invalid Number: ';
PHG_TXT_330	constant varchar2(200)		:= 'To Delete the logo press the button below';

PHG_ALT_331	constant varchar2(200)		:= 'Specify the Photo Format on CD for loading of photos';
PHG_TXT_332	constant varchar2(200)		:= 'FTP Upload';
PHG_TXT_333	constant varchar2(200)		:= 'Private Categories';
PHG_TXT_334	constant varchar2(200)		:= 'a) An Order can be deleted if it is first cancelled.';
PHG_TXT_335	constant varchar2(200)		:= 'b) An Order can be archived if it has been delivered.';
PHG_TXT_336	constant varchar2(200)		:= 'Fax Number';
PHG_TXT_338	constant varchar2(200)		:= 'Roll Id';
PHG_BUT_339	constant varchar2(200)		:= 'Delete Logo';
PHG_BUT_340	constant varchar2(200)		:= 'General Statistics';

PHG_TXT_341	constant varchar2(200)		:= 'Upload Image';
PHG_TXT_342	constant varchar2(200)		:= 'Attach Original to the Web Version';
PHG_TXT_343	constant varchar2(200)		:= 'Add your own private categories to the ones provided. The order number is used to sort the categories in the order that they will appear. Note: A Category without images is not displayed.';
PHG_TXT_344	constant varchar2(200)		:= 'Category Order';
PHG_TXT_345	constant varchar2(200)		:= 'Title';
PHG_TXT_346	constant varchar2(200)		:= 'Fixed: Repeated Fields did not match for umo_id';
PHG_BUT_347	constant varchar2(200)		:= 'Add/Change Categories';
PHG_TXT_348	constant varchar2(200)		:= 'Owner';

PHG_TXT_350	constant varchar2(200)		:= 'To insert a category between other categories just use <B>Category Order</b> that fits between it. Note: You cannot use public category order numbers.';
PHG_TXT_351	constant varchar2(200)		:= 'To Delete a Category Title: If there are no photos attached to the category, then the DELETE anchor will be displayed, allowing the category title to be deleted.';
PHG_TXT_352	constant varchar2(200)		:= 'Utilities';
PHG_TXT_356	constant varchar2(200)		:= 'Product Type';
PHG_TXT_357	constant varchar2(200)		:= 'Photo No';
PHG_ALT_358	constant varchar2(200)		:= 'Logon as Owner';
PHG_ALT_359	constant varchar2(200)		:= 'Daily Usage';
PHG_TXT_360	constant varchar2(200)		:= 'Film Size';

PHG_ALT_361	constant varchar2(200)		:= 'Rotate 90C, 90CC, 180 or Mirror it';
PHG_TXT_362	constant varchar2(200)		:= 'Rotate';
PHG_ALT_363	constant varchar2(200)		:= 'Embed Watermark into the Image';
PHG_TXT_364	constant varchar2(200)		:= 'Loaded Watermark(s)';
PHG_TXT_365	constant varchar2(200)		:= 'Watermark';
PHG_TXT_366	constant varchar2(200)		:= 'Merge Factor';
PHG_TXT_367	constant varchar2(200)		:= 'Mass Modify Data (Rename Images, Change Categories)';
PHG_TXT_368	constant varchar2(200)		:= 'Match Images based on wildcard match';
PHG_TXT_369	constant varchar2(200)		:= 'Try to reduce to size in KB';

PHG_TXT_370	constant varchar2(200)		:= 'Only look at images greater in size than (KB)';
PHG_TXT_371	constant varchar2(200)		:= 'Match Images Film Name Wildcard';
PHG_TXT_372	constant varchar2(200)		:= 'Images must be of type JPEG (Standard Encoded only), GIF, BMP or TIFF. Only JPEG images can be loaded with the No Compression Option.';
PHG_TXT_373	constant varchar2(200)		:= 'Storage Remaining';
PHG_TXT_374	constant varchar2(200)		:= 'Average Bytes per Image';
PHG_TXT_375	constant varchar2(200)		:= 'Estimated Number of Images that can be stored';
PHG_TXT_376	constant varchar2(200)		:= 'Object Type';
PHG_TXT_378	constant varchar2(200)		:= 'Placement';
PHG_TXT_379	constant varchar2(200)		:= 'Top Left';

PHG_ALT_380	constant varchar2(200)		:= 'Customer Accounts';
PHG_TXT_381	constant varchar2(200)		:= 'Top Center';
PHG_ALT_382	constant varchar2(200)		:= 'Image(s) have been deleted.';
PHG_TXT_383	constant varchar2(200)		:= 'Top Right';
PHG_TXT_384	constant varchar2(200)		:= 'Middle Left';
PHG_TXT_385	constant varchar2(200)		:= 'Middle Center';
PHG_ALT_386	constant varchar2(200)		:= 'Modify Customer Account Details';
PHG_ALT_387	constant varchar2(200)		:= 'Current Passwords';
PHG_ALT_388	constant varchar2(200)		:= 'No Results were found. Try using a different search pattern.';

PHG_ALT_390	constant varchar2(200)		:= 'All Categories';
PHG_ALT_391	constant varchar2(200)		:= 'View by';
PHG_ALT_392	constant varchar2(200)		:= 'Image No. Width';
PHG_ALT_394	constant varchar2(200)		:= 'Film Roll';
PHG_ALT_395	constant varchar2(200)		:= 'Load Id';
PHG_ALT_396	constant varchar2(250)		:= 'Please choose an option in the bottom frame to manage images.<BR>e.g. Enabled/Disable Images, Change Names, Reallocate Categories, etc.<BR>To individually manage images, select a category from the left hand frame.';
PHG_ALT_397	constant varchar2(200)		:= ' Display on Main Page';
PHG_ALT_398	constant varchar2(200)		:= ' Special Moment';
PHG_ALT_399	constant varchar2(200)		:= 'Pricing Charge';

PHG_ALT_400	constant varchar2(200)		:= 'Pricing Description';
PHG_TXT_401	constant varchar2(200)		:= 'Middle Right';
PHG_TXT_402	constant varchar2(200)		:= 'Bottom Left';
PHG_TXT_403	constant varchar2(200)		:= 'Bottom Center';
PHG_ALT_404	constant varchar2(200)		:= ' (0-Non Transparent 100-Transparent)';
PHG_ALT_405	constant varchar2(200)		:= 'Crop or cut a section out of the photo';
PHG_ALT_406	constant varchar2(200)		:= 'Recreate the thumbnail with new dimensions';
PHG_ALT_407	constant varchar2(200)		:= 'Crop Photograph';
PHG_TXT_408	constant varchar2(200)		:= 'Y Coord';
PHG_TXT_409	constant varchar2(200)		:= 'X Coord';

PHG_ALT_410	constant varchar2(200)		:= 'Recreate Thumbnail';
PHG_ALT_411	constant varchar2(200)		:= 'Pixel Width';
PHG_ALT_412	constant varchar2(200)		:= 'Error on File Upload: ';
PHG_ALT_413	constant varchar2(200)		:= 'Category Modified';
PHG_ALT_414	constant varchar2(200)		:= 'Resize';
PHG_TXT_415	constant varchar2(200)		:= 'Bottom Right';
PHG_ALT_416	constant varchar2(200)		:= 'Manage your own Gallery. This gallery is available for viewing by all your customers.';
PHG_ALT_417	constant varchar2(200)		:= 'Click on a Image to edit its details';
PHG_ALT_418	constant varchar2(200)		:= 'You currently do not have any Gallery Images. Please add them using the bottom frame';
PHG_ALT_419	constant varchar2(200)		:= 'Load a Gallery Image';

PHG_ALT_421	constant varchar2(200)		:= 'Gallery Image';
PHG_ALT_422	constant varchar2(200)		:= 'Image Title';
PHG_ALT_423	constant varchar2(200)		:= 'Load Gallery Image';
PHG_ALT_424	constant varchar2(200)		:= 'The Image titled: ';
PHG_ALT_425	constant varchar2(200)		:= ' was successfully loaded';
PHG_ALT_426	constant varchar2(200)		:= 'Convert Image to Grayscale';
PHG_ALT_427	constant varchar2(200)		:= 'Do not Compress';
PHG_ALT_428	constant varchar2(200)		:= 'Customers Name';
PHG_ALT_429	constant varchar2(200)		:= 'The following image(s) did not load successfully';

PHG_ALT_431	constant varchar2(200)		:= 'Change Password';
PHG_ALT_432	constant varchar2(200)		:= 'Reports';
PHG_TXT_433	constant varchar2(200)		:= 'Modify your password';
PHG_TXT_434	constant varchar2(200)		:= 'Restore Image from Backup';
PHG_TXT_435	constant varchar2(200)		:= 'Most Popular Images Purchased';
PHG_TXT_436	constant varchar2(200)		:= 'Customer Job Reference';
PHG_TXT_437	constant varchar2(200)		:= 'Online Chat Forum';
PHG_TXT_438	constant varchar2(200)		:= 'Fixed: Records missing extra field';
PHG_TXT_439	constant varchar2(200)		:= 'Quick Category Change';
PHG_TXT_440	constant varchar2(200)		:= 'Start Load ID';

PHG_TXT_441	constant varchar2(200)		:= 'End Load ID';
PHG_TXT_442	constant varchar2(200)		:= 'Change Categories';
PHG_TXT_443	constant varchar2(200)		:= 'Numbers';
PHG_TXT_445	constant varchar2(200)		:= 'Charge Plan Type';
PHG_TXT_446	constant varchar2(200)		:= 'Renewal Month';
PHG_TXT_448	constant varchar2(200)		:= 'Look at the Readme Notes for this Version';
PHG_TXT_450	constant varchar2(200)		:= 'Transparent Pixel';

PHG_TXT_451	constant varchar2(200)		:= 'WHITE';
PHG_TXT_452	constant varchar2(200)		:= 'Pixel at Coord (0,0)';
PHG_TXT_453	constant varchar2(200)		:= 'Reduce to Pixel Width';
PHG_TXT_454	constant varchar2(200)		:= 'Only look at Photos with a pixel width greater than';
PHG_TXT_455	constant varchar2(200)		:= 'Reduce to Pixel Height';
PHG_TXT_456	constant varchar2(200)		:= 'Only look at Photos with a pixel height greater than';
PHG_TXT_457	constant varchar2(200)		:= 'The watermark is too wide to embed in the image';
PHG_TXT_458	constant varchar2(200)		:= 'The watermark is too high to embed in the image';
PHG_TXT_459	constant varchar2(200)		:= 'Watermark placement could not be calculated';

PHG_TXT_460	constant varchar2(200)		:= 'Downloaded Images';
PHG_TXT_461	constant varchar2(200)		:= 'Modifications made to Images';
PHG_TXT_462	constant varchar2(200)		:= 'No Modifications have been made';
PHG_TXT_463	constant varchar2(200)		:= 'Date Modified';
PHG_TXT_464	constant varchar2(200)		:= 'Change Type';
PHG_TXT_465	constant varchar2(200)		:= 'Extra Details';
PHG_TXT_466	constant varchar2(200)		:= '90C';
PHG_TXT_467	constant varchar2(200)		:= '90CC';
PHG_TXT_468	constant varchar2(200)		:= '180';
PHG_TXT_469	constant varchar2(200)		:= 'MIRROR';
PHG_TXT_470	constant varchar2(200)		:= 'Price Book';

PHG_TXT_471	constant varchar2(200)		:= 'You have not created an Order Style.';
PHG_TXT_472	constant varchar2(200)		:= 'An Order Style contains business requirements for and Order';
PHG_TXT_473	constant varchar2(200)		:= 'Click here to create an Order Style';
PHG_TXT_474	constant varchar2(200)		:= 'This Ordering Style is valid for this customer until';
PHG_TXT_475	constant varchar2(200)		:= 'Use this Order Style when the other Order Style becomes invalid';
PHG_TXT_476	constant varchar2(200)		:= 'Photo Laboratory handles all Customer Orders';
PHG_TXT_477	constant varchar2(200)		:= 'You must enter in a date after todays date';
PHG_TXT_478	constant varchar2(200)		:= 'Customer Price Book Details';
PHG_TXT_479	constant varchar2(200)		:= 'Code';
PHG_TXT_480	constant varchar2(200)		:= 'Item Name';

PHG_TXT_481	constant varchar2(200)		:= 'Sale Price';
PHG_TXT_482	constant varchar2(200)		:= 'Cross Shape';
PHG_TXT_483	constant varchar2(200)		:= 'Diagonal Shape';
PHG_TXT_484	constant varchar2(200)		:= 'Large Rotate and Watermark';
PHG_TXT_485	constant varchar2(200)		:= 'WMark';
PHG_TXT_486	constant varchar2(200)		:= 'Mirr.';
PHG_TXT_487	constant varchar2(200)		:= 'Business Hours Min';
PHG_TXT_489	constant varchar2(200)		:= 'Sunday';
PHG_TXT_490	constant varchar2(200)		:= 'Monday';

PHG_TXT_491	constant varchar2(200)		:= 'Tuesday';
PHG_TXT_492	constant varchar2(200)		:= 'Wednesday';
PHG_TXT_493	constant varchar2(200)		:= 'Thursday';
PHG_TXT_494	constant varchar2(200)		:= 'Friday';
PHG_TXT_495	constant varchar2(200)		:= 'Saturday';
PHG_TXT_496	constant varchar2(200)		:= 'Business Days';
PHG_TXT_497	constant varchar2(200)		:= 'Private Gallery Web Site';
PHG_TXT_498	constant varchar2(200)		:= 'Customer Purchase Request <PHOTOGRAPHER> Contact Details';
PHG_TXT_499	constant varchar2(200)		:= 'An expiry date and an alternative price book must both be specified';
PHG_TXT_500	constant varchar2(200)		:= 'Find Images that';

PHG_TXT_501	constant varchar2(200)		:= 'Delete Query';
PHG_TXT_502	constant varchar2(200)		:= 'Previous Queries Run';
PHG_TXT_503	constant varchar2(200)		:= 'Query Details';
PHG_TXT_504	constant varchar2(200)		:= 'Name of Query (optional)';
PHG_TXT_505	constant varchar2(200)		:= 'Matches';
PHG_TXT_506	constant varchar2(200)		:= 'Starts With';
PHG_TXT_507	constant varchar2(200)		:= 'Exactly Matches';
PHG_TXT_508	constant varchar2(200)		:= 'Sounds Like';
PHG_TXT_509	constant varchar2(200)		:= 'And';
PHG_TXT_510	constant varchar2(200)		:= 'Or';

PHG_TXT_511	constant varchar2(200)		:= 'Not';
PHG_TXT_512	constant varchar2(200)		:= 'Run Advanced Search';
PHG_TXT_513	constant varchar2(200)		:= 'Word in Image';
PHG_TXT_514	constant varchar2(200)		:= 'Rename Category';
PHG_TXT_515	constant varchar2(200)		:= 'Current Category Name';
PHG_TXT_516	constant varchar2(200)		:= 'New Category Name';
PHG_TXT_517	constant varchar2(200)		:= 'Choose the New Category Name';
PHG_TXT_518	constant varchar2(200)		:= 'The Screen will redisplay allowing you to map the Categories from current name to the new name';
PHG_TXT_519	constant varchar2(200)		:= 'Recreated thumbnail for Photo';
PHG_TXT_520	constant varchar2(200)		:= 'Error resizing';

PHG_TXT_521	constant varchar2(200)		:= 'No Category';
PHG_TXT_522	constant varchar2(200)		:= 'The Watermark is too large to be used';
PHG_TXT_523	constant varchar2(200)		:= 'There are no images available';
PHG_TXT_524	constant varchar2(200)		:= 'Change Roll';
PHG_TXT_525	constant varchar2(200)		:= 'Change Film Size';
PHG_TXT_526	constant varchar2(200)		:= 'Change Film Type';
PHG_TXT_527	constant varchar2(200)		:= 'Move/Copy Images to another Account';
PHG_TXT_528	constant varchar2(200)		:= 'Link to Other Object';
PHG_TXT_529	constant varchar2(200)		:= 'Choose the Customer';
PHG_TXT_530	constant varchar2(200)		:= 'Move Images';

PHG_TXT_531	constant varchar2(200)		:= 'The Screen will redisplay allowing you to move/copy images from this Account to another Account';
PHG_TXT_532	constant varchar2(200)		:= 'If no Start and End Load is used then all images are moved';
PHG_TXT_533	constant varchar2(200)		:= 'FTP Location';
PHG_TXT_534	constant varchar2(200)		:= 'Copy Images';

--
-- SLD
--

SLD_TXT_002	constant varchar2(200)		:= 'Edit Slideshow';
SLD_TXT_003	constant varchar2(200)		:= 'Edit slides by clicking on them. Insert a new slide using the controller at the bottom of the screen.';
SLD_TXT_004	constant varchar2(200)		:= 'Delete';
SLD_TXT_005	constant varchar2(200)		:= 'Slide Type';
SLD_TXT_007	constant varchar2(200)		:= 'Insert Slide Before';
SLD_TXT_008	constant varchar2(200)		:= '[Del]';
SLD_TXT_009	constant varchar2(200)		:= 'There are currently no slides. Create a new slide from the controller at the bottom of the screen.';
SLD_TXT_010	constant varchar2(200)		:= 'Press the button to Delete this Slideshow ';

SLD_TXT_011	constant varchar2(200)		:= 'Delete Slideshow';
SLD_TXT_012	constant varchar2(200)		:= 'Run Slideshow';
SLD_TXT_013	constant varchar2(200)		:= 'Slideshow Deleted. To create a new slideshow enter in the details below';
SLD_TXT_014	constant varchar2(200)		:= 'Edit Slide #';
SLD_TXT_015	constant varchar2(200)		:= 'Edit Slide Show Details';
SLD_TXT_016	constant varchar2(200)		:= 'Please Enter in the Details to Create a new slide show';
SLD_TXT_017	constant varchar2(200)		:= 'Create New Slide Show';
SLD_TXT_019	constant varchar2(200)		:= 'Name of the Slideshow';
SLD_TXT_020	constant varchar2(200)		:= 'Slide refresh rate in seconds';

SLD_TXT_021	constant varchar2(200)		:= 'None';
SLD_TXT_022	constant varchar2(200)		:= 'Small';
SLD_TXT_023	constant varchar2(200)		:= 'Medium';
SLD_TXT_024	constant varchar2(200)		:= 'Large';
SLD_TXT_025	constant varchar2(200)		:= 'Frame Size';
SLD_TXT_026	constant varchar2(200)		:= 'Background Colour';
SLD_TXT_027	constant varchar2(200)		:= 'Error: This name already exists.';
SLD_TXT_028	constant varchar2(200)		:= ' Edit Slideshow Details';
SLD_TXT_029	constant varchar2(200)		:= 'Modify slideshow details then press the SAVE button below. To load a background image instead of a colour click on the LOAD button below.';

SLD_BUT_031	constant varchar2(200)		:= 'Quick Create of all Slides - Mixed';
SLD_TXT_032	constant varchar2(200)		:= 'Background Colour Not Used';
SLD_TXT_033	constant varchar2(200)		:= 'Background Image Used';
SLD_TXT_034	constant varchar2(200)		:= 'Error: A Slideshow Name must be entered';
SLD_TXT_035	constant varchar2(200)		:= 'Slide Details successfully updated';
SLD_TXT_038	constant varchar2(200)		:= 'Slide Deleted';
SLD_TXT_039	constant varchar2(200)		:= 'Slide Modified';
SLD_TXT_040	constant varchar2(200)		:= 'Slide Modification Completed';

SLD_TXT_041	constant varchar2(200)		:= 'Note: Thumbnails shown here, real photos displayed in actual slide show.';
SLD_TXT_042	constant varchar2(200)		:= 'Slide Name';
SLD_TXT_043	constant varchar2(200)		:= 'Slide Refresh';
SLD_TXT_044	constant varchar2(200)		:= 'This is the Last Slide';
SLD_TXT_045	constant varchar2(200)		:= 'Slideshow Stopped: ';
SLD_TXT_046	constant varchar2(200)		:= 'Goto Slide';
SLD_TXT_047	constant varchar2(200)		:= 'Click to Add to Shopping Trolley';
SLD_TXT_048	constant varchar2(200)		:= '  Slide Shows';
SLD_TXT_049	constant varchar2(200)		:= 'Click on the Slideshow below to view it';

SLD_TXT_050	constant varchar2(200)		:= ' Slide Background Image';
SLD_BUT_051	constant varchar2(200)		:= 'Quick Create of all Slides';
SLD_BUT_052	constant varchar2(200)		:= 'Quick Create using Special Moments';
SLD_BUT_053	constant varchar2(200)		:= 'SAVE Slide Show Details';
SLD_BUT_054	constant varchar2(200)		:= 'LOAD a Background Image';
SLD_ALT_056	constant varchar2(200)		:= 'Single Image';
SLD_ALT_057	constant varchar2(200)		:= 'Two Photos Horizontal Split';
SLD_ALT_058	constant varchar2(200)		:= 'Two Photos Vertical Split';
SLD_ALT_059	constant varchar2(200)		:= 'Three Photos Left split';

SLD_ALT_060	constant varchar2(200)		:= 'Three Photos Right split';
SLD_ALT_061	constant varchar2(200)		:= 'Four Photos';
SLD_ALT_062	constant varchar2(200)		:= 'Four Photos Alternating';
SLD_ALT_063	constant varchar2(200)		:= 'Three Photos Diagonal';
SLD_ALT_064	constant varchar2(200)		:= 'Three Photos Large Middle';
SLD_ALT_065	constant varchar2(200)		:= 'Four Photos Diamond Shape';
SLD_ALT_066	constant varchar2(200)		:= 'Click to Edit Slide';
SLD_BUT_067	constant varchar2(200)		:= 'Modify Slide';
SLD_BUT_068	constant varchar2(200)		:= 'Add Slide';
SLD_BUT_069	constant varchar2(200)		:= 'Insert Slide';

SLD_BUT_070	constant varchar2(200)		:= 'Return with Modification';
SLD_BUT_071	constant varchar2(200)		:= 'Start Slideshow Again';
SLD_BUT_072	constant varchar2(200)		:= 'Return to Main Screen';
SLD_BUT_073	constant varchar2(200)		:= 'Pause Slideshow';
SLD_BUT_074	constant varchar2(200)		:= 'Resume Slideshow';
SLD_TXT_075	constant varchar2(200)		:= 'To use this page: Click the BROWSE button to locate the GIF file to be used as the background image.' ;
SLD_TXT_076	constant varchar2(200)		:= 'Slide Background Does Not Exist';
SLD_TXT_077	constant varchar2(200)		:= 'Quick Create based on a Category';
SLD_TXT_078	constant varchar2(200)		:= 'Quick Create based on a Film Roll';

SLD_TXT_080	constant varchar2(200)		:= 'Modify Background Image';
SLD_TXT_081	constant varchar2(200)		:= 'Background Image Management Completed';
SLD_TXT_082	constant varchar2(200)		:= 'Return to Slide Menu';
SLD_TXT_084	constant varchar2(200)		:= 'Press to Enlarge';
SLD_TXT_085	constant varchar2(200)		:= 'Add New Slide';
SLD_TXT_086	constant varchar2(200)		:= 'Slide Shows';
SLD_TXT_087	constant varchar2(200)		:= 'Next';
SLD_TXT_088	constant varchar2(200)		:= 'Prev';
SLD_TXT_089	constant varchar2(200)		:= 'Run Slide Show Continuously';
SLD_TXT_090	constant varchar2(200)		:= 'Play Slide Show Once';


--
-- ORD
--

ORD_TXT_001	constant varchar2(200)		:= 'Invoice with Thumbnails';
ORD_TXT_002	constant varchar2(200)		:= 'Invoice without Thumbnails';
ORD_TXT_004	constant varchar2(200)		:= 'GST Report';
ORD_TXT_005	constant varchar2(200)		:= 'Welcome to the Ordering System';
ORD_TXT_006	constant varchar2(200)		:= 'Ordering is as simple as following seven simple steps.';
ORD_TXT_007	constant varchar2(200)		:= 'At any time you can navigate to an earlier screen and change your details.';
ORD_TXT_008	constant varchar2(200)		:= 'Click on <B>Next</B> to move to the next screen.';
ORD_ALT_009	constant varchar2(200)		:= 'Go to the Shipping Address Screen';
ORD_TXT_010	constant varchar2(200)		:= 'Next to the Shipping Address Screen';

ORD_TXT_011	constant varchar2(200)		:= 'Shipping Address Details';
ORD_TXT_012	constant varchar2(200)		:= 'Please enter in Shipping Details. Your items will be sent to this address.';
ORD_TXT_013	constant varchar2(200)		:= 'Shipping Cost';
ORD_TXT_014	constant varchar2(200)		:= 'Local/International';
ORD_TXT_015	constant varchar2(200)		:= 'Previous to the<BR>Welcome Screen';
ORD_TXT_016	constant varchar2(200)		:= 'Next to the<BR>Confirm Items Screen';
ORD_TXT_017	constant varchar2(200)		:= 'Please review the items you have ordered.';
ORD_TXT_018	constant varchar2(200)		:= 'Previous to the<BR>Shipping Screen';
ORD_TXT_019	constant varchar2(200)		:= 'Next to the<BR>Gift Wrap Screen';

ORD_TXT_021	constant varchar2(200)		:= 'Order has been recalculated';
ORD_TXT_022	constant varchar2(200)		:= 'Gift Wrapping Details';
ORD_TXT_023	constant varchar2(200)		:= 'Cost for Gift Wrapping';
ORD_TXT_024	constant varchar2(200)		:= 'Previous to the<BR>Confirm Screen';
ORD_TXT_025	constant varchar2(200)		:= 'Next to the<BR>Order Tracking Screen';
ORD_TXT_026	constant varchar2(200)		:= 'Order Tracking Details';
ORD_TXT_027	constant varchar2(200)		:= 'Please enter in Order Tracking Details. Information Here is Optional.';
ORD_TXT_028	constant varchar2(200)		:= 'If you enter in an email address, order shipping information will be sent to you.<BR>Provide a password and you can check the status of your order online.';
ORD_TXT_029	constant varchar2(200)		:= 'Your email address';
ORD_TXT_030	constant varchar2(200)		:= 'Order Tracking Password';

ORD_TXT_031	constant varchar2(200)		:= 'Email me when the Order has been confirmed';
ORD_TXT_032	constant varchar2(200)		:= 'Previous to the<BR>Gift Wrap Screen';
ORD_TXT_033	constant varchar2(200)		:= 'Next to the<BR>Payment Details Screen';
ORD_TXT_034	constant varchar2(200)		:= 'Payment Details';
ORD_TXT_035	constant varchar2(200)		:= 'Previous to the<BR>Order Tracking Screen';
ORD_TXT_036	constant varchar2(200)		:= 'Next to the<BR>Payment Confirmation Screen';
ORD_TXT_037	constant varchar2(200)		:= 'Please list all Phone Numbers that we can contact you on:';
ORD_TXT_038	constant varchar2(200)		:= 'Order Confirmation' ;
ORD_TXT_039	constant varchar2(200)		:= 'Confirm Payment';
ORD_TXT_040	constant varchar2(200)		:= 'Click on the Confirm Payment Icon below to agree to this purchase';

ORD_TXT_041	constant varchar2(200)		:= 'Cost of Goods';
ORD_TXT_042	constant varchar2(200)		:= '<PHOTOGRAPHER> Discount';
ORD_TXT_043	constant varchar2(200)		:= 'Discount Cost of Goods';
ORD_TXT_044	constant varchar2(200)		:= 'Shipping Cost (Local)';
ORD_TXT_045	constant varchar2(200)		:= 'Shipping Cost (International)';
ORD_TXT_046	constant varchar2(200)		:= 'Gift Wrap Cost';

ORD_TXT_061	constant varchar2(200)		:= 'Cancel this Order';
ORD_ALT_062	constant varchar2(200)		:= 'Previous Screen';
ORD_TXT_064	constant varchar2(200)		:= 'Confirmation of your Purchase Request : ';
ORD_TXT_065	constant varchar2(200)		:= 'At any time you can check on the status of your order by going to the following site: ';
ORD_TXT_066	constant varchar2(200)		:= 'Just enter in your Purchase Request Number and Password.';
ORD_TXT_067	constant varchar2(200)		:= 'Order Cancellation';
ORD_TXT_069	constant varchar2(200)		:= 'If you cancel this order all items in the shopping basket will be deleted.';
ORD_TXT_070	constant varchar2(200)		:= 'Click on the Icon below to Confirm Cancellation of this Purchase Request';

ORD_ALT_071	constant varchar2(200)		:= 'Confirm Cancellation of Purchase Request #';
ORD_TXT_072	constant varchar2(200)		:= 'Previous to the<BR>Confirm Order Screen';
ORD_TXT_073	constant varchar2(200)		:= 'Purchase Request has been cancelled: ';
ORD_TXT_074	constant varchar2(200)		:= 'Purchase Request has been Cancelled';
ORD_TXT_076	constant varchar2(200)		:= 'This Order has been Confirmed';
ORD_TXT_077	constant varchar2(200)		:= 'You can Cancel this Order or Create a New One.';

ORD_TXT_081	constant varchar2(200)		:= 'Order Status is';
ORD_TXT_082	constant varchar2(200)		:= 'The Status of this Order cannot be changed';
ORD_TXT_085	constant varchar2(200)		:= 'Order Status Display';
ORD_TXT_086	constant varchar2(200)		:= 'This Page is for authorised users only.';
ORD_TXT_087	constant varchar2(200)		:= 'You must have a valid Purchase Request and Password to use this page.';
ORD_TXT_088	constant varchar2(200)		:= 'Your Purchase Request Number';
ORD_TXT_089	constant varchar2(200)		:= 'Your Password that you assigned to this Order';
ORD_TXT_090	constant varchar2(200)		:= 'Display Purchase Request Status';

ORD_TXT_091	constant varchar2(200)		:= 'Invalid Purchase Request Number Entered';
ORD_TXT_093	constant varchar2(200)		:= 'Invalid Password Entered';
ORD_TXT_094	constant varchar2(200)		:= 'Order Status Display for Purchase Request : ';
ORD_TXT_095	constant varchar2(200)		:= 'The following page gives the details about your Purchase Request.';
ORD_TXT_096	constant varchar2(200)		:= 'Purchase Request Status';
ORD_TXT_097	constant varchar2(200)		:= 'Thankyou for your use of the Ordering System';
ORD_TXT_100	constant varchar2(200)		:= 'Your Purchase Request has been fulfilled: ';

ORD_TXT_101	constant varchar2(200)		:= 'Your Purchase Request has been confirmed: ';
ORD_TXT_102	constant varchar2(200)		:= 'Shipping';
ORD_TXT_105	constant varchar2(200)		:= '<PHOTOGRAPHER> Customer Discount';
ORD_TXT_107	constant varchar2(200)		:= 'Extra Discount just for this Order (%) eg. 25';
ORD_TXT_108	constant varchar2(200)		:= 'Grand Total';
ORD_TXT_109	constant varchar2(200)		:= 'Comments or Extra Details about this Order';
ORD_TXT_111	constant varchar2(200)		:= 'Confirm Items';

ORD_TXT_120	constant varchar2(200)		:= 'PreOrder';
ORD_TXT_121	constant varchar2(200)		:= 'Ordered';
ORD_TXT_122	constant varchar2(200)		:= 'Customer Purchase Request Tracking';
ORD_TXT_123	constant varchar2(200)		:= 'This customer does not wish to have their Purchase Request tracked';
ORD_TXT_124	constant varchar2(200)		:= 'To be notified of an event you must supply a contact email address and password';
ORD_TXT_125	constant varchar2(200)		:= 'Processed by Lab';
ORD_TXT_127	constant varchar2(200)		:= 'Archived';
ORD_TXT_128	constant varchar2(200)		:= 'Customer Cancelled';
ORD_TXT_129	constant varchar2(200)		:= 'Photographer Cancelled';

ORD_TXT_132	constant varchar2(200)		:= 'Outstanding Orders';
ORD_TXT_133	constant varchar2(200)		:= 'Edit Order';
ORD_TXT_134	constant varchar2(200)		:= 'Edit Order Details';
ORD_TXT_135	constant varchar2(200)		:= 'Update Form Details';
ORD_TXT_136	constant varchar2(200)		:= 'Return to listing of Orders';
ORD_TXT_138	constant varchar2(200)		:= 'Order Form Details';
ORD_TXT_139	constant varchar2(200)		:= 'View by Client Name';
ORD_TXT_140	constant varchar2(200)		:= 'View All Clients';

ORD_TXT_141	constant varchar2(200)		:= 'View all Orders';
ORD_TXT_142	constant varchar2(200)		:= 'View Orders to be Processed';
ORD_TXT_143	constant varchar2(200)		:= 'Total Orders';
ORD_TXT_144	constant varchar2(200)		:= 'Payment Not Received';
ORD_TXT_145	constant varchar2(200)		:= 'Payment Received';
ORD_TXT_146	constant varchar2(200)		:= 'Payment Problems';
-- ORD_TXT_147	constant varchar2(200)		:= 'Photographer ABN';
ORD_TXT_148	constant varchar2(200)		:= 'Total Charge';
ORD_TXT_149	constant varchar2(200)		:= 'Payment Status';

ORD_TXT_150	constant varchar2(200)		:= 'Date Payment Received';
ORD_TXT_151	constant varchar2(200)		:= 'Bad Date Entered';
ORD_TXT_152	constant varchar2(200)		:= 'Bad Total Cost Entered';
ORD_TXT_153	constant varchar2(200)		:= 'Date Due';
ORD_TXT_154	constant varchar2(200)		:= 'Days Outstanding';
ORD_TXT_155	constant varchar2(200)		:= 'There are no outstanding Invoices';
ORD_TXT_156	constant varchar2(200)		:= 'Customer Receipt';
ORD_TXT_157	constant varchar2(200)		:= 'Original Images are available for Download';
ORD_TXT_158	constant varchar2(200)		:= 'Please read the following terms and conditions. Press Accept or Decline.';
ORD_TXT_159	constant varchar2(200)		:= 'ACCEPT';

ORD_TXT_160	constant varchar2(200)		:= 'DECLINE';
ORD_TXT_161	constant varchar2(200)		:= 'Images cannot be downloaded unless you agree to the terms and conditions.';
ORD_TXT_162	constant varchar2(200)		:= 'Unable to locate HTML file to Display';
ORD_TXT_163	constant varchar2(200)		:= 'The following files are available for Download';
ORD_TXT_164	constant varchar2(200)		:= 'No files are available to be downloaded';
ORD_TXT_165	constant varchar2(200)		:= 'Web Quality Images are available for Download';

ORD_TXT_171	constant varchar2(200)		:= 'Cost';
ORD_TXT_172	constant varchar2(200)		:= 'Click Here to Pay by Credit Card and Enter the Secure Payment Site';
ORD_TXT_173	constant varchar2(200)		:= 'If you have problems entering the secure site, then click here';
ORD_TXT_175	constant varchar2(200)		:= 'Pay by Phone';
ORD_TXT_176	constant varchar2(200)		:= 'Choose a Payment Method';
ORD_TXT_177	constant varchar2(200)		:= 'Credit Card Payment Details';
ORD_TXT_179	constant varchar2(200)		:= 'Payment Method';

ORD_TXT_180	constant varchar2(200)		:= 'Phone';
ORD_TXT_181	constant varchar2(200)		:= 'Secure Credit Card';
ORD_TXT_182	constant varchar2(200)		:= 'Merchant Facilities';
ORD_TXT_183	constant varchar2(200)		:= 'Email me if an issue occurs';
ORD_TXT_184	constant varchar2(200)		:= 'Email me when the Order has been shipped';
ORD_TXT_185	constant varchar2(200)		:= 'Quantity';
ORD_TXT_186	constant varchar2(200)		:= 'Total Distinct Orders';
ORD_TXT_187	constant varchar2(200)		:= 'Contact';
ORD_TXT_188	constant varchar2(200)		:= 'Date';
ORD_TXT_189	constant varchar2(200)		:= 'Manufacturer Purchase Request Id';

ORD_TXT_190	constant varchar2(200)		:= 'Lab Details';
ORD_TXT_191	constant varchar2(200)		:= 'Is this Order direct from the Customer?';
ORD_TXT_192	constant varchar2(200)		:= 'Direct?';
ORD_TXT_193	constant varchar2(200)		:= 'Direct to Lab Order';
ORD_TXT_194	constant varchar2(200)		:= 'ALL';
ORD_TXT_195	constant varchar2(200)		:= 'Lab Transaction Charge';
ORD_TXT_196	constant varchar2(200)		:= 'Photographer/Client Receipt';
ORD_TXT_197	constant varchar2(200)		:= 'Invoice';
ORD_TXT_198	constant varchar2(200)		:= 'Lab Costs';
ORD_TXT_199	constant varchar2(200)		:= 'Order Completed';

ORD_TXT_200	constant varchar2(200)		:= 'New';
ORD_TXT_201	constant varchar2(200)		:= 'Active';
ORD_TXT_202	constant varchar2(200)		:= 'Processing';
ORD_TXT_203	constant varchar2(200)		:= 'Sent to Lab';
ORD_TXT_204	constant varchar2(200)		:= 'Received by Lab';
ORD_TXT_205	constant varchar2(200)		:= 'Lab Managed';
ORD_TXT_206	constant varchar2(200)		:= 'PreOrders';
ORD_TXT_207	constant varchar2(200)		:= 'Cancelled';
ORD_TXT_208	constant varchar2(200)		:= 'Customer Status';
ORD_TXT_210	constant varchar2(200)		:= 'On Hold';

ORD_TXT_211	constant varchar2(200)		:= 'Lab Problems';
ORD_TXT_213	constant varchar2(200)		:= 'Note: This Report Covers all Customers Orders which the Laboratory has Managed';
ORD_TXT_214	constant varchar2(200)		:= 'Please Include the Country and Area Code for';
ORD_TXT_215	constant varchar2(200)		:= 'Please enter in Gift Wrap Details. Information Here is Optional.';
ORD_TXT_216	constant varchar2(200)		:= 'Credit Card Response Code';
ORD_TXT_217	constant varchar2(200)		:= 'Credit Card Response Text';
ORD_TXT_218	constant varchar2(200)		:= 'Credit Card Receipt Number';
ORD_TXT_219	constant varchar2(200)		:= 'Your Transaction was not approved';
ORD_TXT_220	constant varchar2(200)		:= 'Nett Income';

ORD_TXT_222	constant varchar2(200)		:= 'Purchased';
ORD_TXT_223	constant varchar2(200)		:= 'time(s).';
ORD_TXT_224	constant varchar2(200)		:= 'Customers who purchased these Images also Purchased' ;
ORD_TXT_225	constant varchar2(200)		:= 'Currency Table';
ORD_TXT_226	constant varchar2(200)		:= 'Disclaimer: The currency rates shown here are an approximation and should not be treated as the actual value.';
ORD_TXT_227	constant varchar2(200)		:= 'Actual value will vary on foreign exchange rates, credit card exchange fees and bank charges.';
ORD_TXT_228	constant varchar2(200)		:= 'View in Other Currencies.';
ORD_TXT_229	constant varchar2(200)		:= 'Date Currency Updated';
ORD_TXT_230	constant varchar2(200)		:= 'Rate';

ORD_TXT_231	constant varchar2(200)		:= 'Total in Currency';

--
-- LAB
--

LAB_TXT_001	constant varchar2(200)		:=  'Options';
LAB_TXT_002	constant varchar2(200)		:=  'Home';
LAB_TXT_006	constant varchar2(200)		:=  'Product Price List Book';
LAB_TXT_007	constant varchar2(200)		:=  'Add a New Product';
LAB_TXT_008	constant varchar2(200)		:=  'Manufacturer Details';
LAB_TXT_009	constant varchar2(200)		:=  'Manufacturer Name';
LAB_TXT_010	constant varchar2(200)		:=  'Edit Product Details';

LAB_BUT_011	constant varchar2(200)		:=  'Modify Manufacturer Details';
LAB_TXT_012	constant varchar2(200)		:=  'Name of Item';
LAB_TXT_014	constant varchar2(200)		:=  'Type of Product';
LAB_TXT_015	constant varchar2(200)		:=  'Price';
LAB_TXT_016	constant varchar2(200)		:=  'Tax';
LAB_TXT_017	constant varchar2(200)		:=  'Commission';
LAB_TXT_018	constant varchar2(200)		:=  'Product Price was valid until date';
LAB_TXT_019	constant varchar2(200)		:=  'Price of the Product';
LAB_TXT_020	constant varchar2(200)		:=  'Change the Price of the Product';

LAB_TXT_021	constant varchar2(200)		:=  'New Price';
LAB_TXT_022	constant varchar2(200)		:=  'Tax (optional)';
LAB_TXT_023	constant varchar2(200)		:=  'Commission (optional)';
LAB_BUT_024	constant varchar2(200)		:=  'Add Product';
LAB_BUT_025	constant varchar2(200)		:=  'Modify Product Details';
LAB_BUT_026	constant varchar2(200)		:=  'Delete Product';
LAB_TXT_028	constant varchar2(200)		:=  'Unable to Delete as there are Child Products Dependent on this Product';
LAB_TXT_029	constant varchar2(200)		:=  'Product has been deleted';
LAB_TXT_030	constant varchar2(200)		:=  'You must enter is a name for this product';

LAB_TXT_031	constant varchar2(200)		:=  'Product Successfully Added';
LAB_TXT_032	constant varchar2(200)		:=  'Product Successfully Modified';
LAB_TXT_033	constant varchar2(200)		:=  'Product Order Summary';
LAB_TXT_034	constant varchar2(200)		:=  'Nett Income / Lab Commission Report';
LAB_TXT_035	constant varchar2(200)		:=  'Most Heavily Used Clients';
LAB_TXT_036	constant varchar2(200)		:=  'Outstanding Accounts';
LAB_TXT_037	constant varchar2(200)		:=  'Return to the Reports Menu';
LAB_TXT_038	constant varchar2(200)		:=  'Days Invoice is Due';
LAB_TXT_039	constant varchar2(200)		:=  'Number of Customer Accounts';
LAB_TXT_040	constant varchar2(200)		:=  'Total Revenue';

LAB_TXT_041	constant varchar2(200)		:=  'Average Revenue per Customer Account';
LAB_TXT_042	constant varchar2(200)		:=  'Manufacturer Code';
LAB_TXT_043	constant varchar2(200)		:=  'Cross Reference Code';
LAB_TXT_044	constant varchar2(200)		:=  'Discounted';
LAB_TXT_045	constant varchar2(200)		:=  'Reverse Engineer Price Book';
LAB_TXT_046	constant varchar2(200)		:=  'File Name';
LAB_TXT_047	constant varchar2(200)		:=  'Load Price Book';
LAB_TXT_048	constant varchar2(200)		:=  'Ignore First Line';
LAB_TXT_050	constant varchar2(200)		:=  'Encountered an Error Loading the File';

LAB_TXT_052	constant varchar2(200)		:=  'Product Name';
LAB_TXT_053	constant varchar2(200)		:=  'Manufacturer Cross Ref Code';
LAB_TXT_054	constant varchar2(200)		:=  'Price $999,999.99';
LAB_TXT_055	constant varchar2(200)		:=  'Is Discounted Y or N';
LAB_TXT_056	constant varchar2(200)		:=  'Price Book: Default REPRINT';
LAB_TXT_057	constant varchar2(200)		:=  'Type of Product: Default All';
LAB_TXT_058	constant varchar2(200)		:=  'File must be comma delimited';
LAB_TXT_059	constant varchar2(200)		:=  'Price Book Utilities';
LAB_TXT_060	constant varchar2(200)		:=  'Total Number of Entries';

LAB_TXT_061	constant varchar2(200)		:=  'Delete this Price Book';
LAB_TXT_062	constant varchar2(200)		:=  'Some Items are used by a Photographer/Client';
LAB_TXT_063	constant varchar2(200)		:=  'The following Clients use this Item';
-- LAB_TXT_064	constant varchar2(200)		:=  'This Item is not being used by a Photographer/Client';
LAB_TXT_065	constant varchar2(200)		:=  'What they are charging for the Item';
LAB_TXT_066	constant varchar2(200)		:=  'A Manufacturer Code must be entered';
LAB_TXT_067	constant varchar2(200)		:=  'This Manufacturer Code is not unique.';
LAB_TXT_068	constant varchar2(200)		:=  'Delete Items not used by a Photographer/Client';
LAB_TXT_069	constant varchar2(200)		:=  'Year From';
LAB_TXT_070	constant varchar2(200)		:=  'Month From';

LAB_TXT_071	constant varchar2(200)		:=  'Year To';
LAB_TXT_072	constant varchar2(200)		:=  'Month To';
LAB_TXT_073	constant varchar2(200)		:=  'January';
LAB_TXT_074	constant varchar2(200)		:=  'February';
LAB_TXT_075	constant varchar2(200)		:=  'March';
LAB_TXT_076	constant varchar2(200)		:=  'April';
LAB_TXT_077	constant varchar2(200)		:=  'May';
LAB_TXT_078	constant varchar2(200)		:=  'June';
LAB_TXT_079	constant varchar2(200)		:=  'July';
LAB_TXT_080	constant varchar2(200)		:=  'August';

LAB_TXT_081	constant varchar2(200)		:=  'September';
LAB_TXT_082	constant varchar2(200)		:=  'October';
LAB_TXT_083	constant varchar2(200)		:=  'November';
LAB_TXT_084	constant varchar2(200)		:=  'December';
LAB_TXT_085	constant varchar2(200)		:=  'Sort By Name';
LAB_TXT_086	constant varchar2(200)		:=  'Sort By Load Id';
LAB_TXT_087	constant varchar2(200)		:=  'Sort By Code';

end lng;

/
