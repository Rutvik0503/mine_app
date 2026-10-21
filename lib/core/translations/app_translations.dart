import 'package:get/get.dart';

/// GetX translations for Virtual Mining Empire. Keys are the English UI
/// strings themselves (GetX's `.tr` looks the current string up as a key,
/// and falls back to returning it unchanged if missing) - covers the core
/// gameplay loop (auth, home, mining, farm, rewards, store, profile,
/// settings, machines, referrals) plus common empty/error states. Deeper
/// screens (missions/achievements/leaderboard/notifications/streak body
/// copy) keep their titles translated but their inner micro-copy is still
/// English-only - a follow-up pass can extend the maps below the same way.
class AppTranslations extends Translations {
  // GetX wants locale -> {key -> text}; the maps below are written key-first
  // (easier to read/extend), so flip them once.
  static final Map<String, Map<String, String>> _byLocale = _flip();

  static Map<String, Map<String, String>> _flip() {
    final out = <String, Map<String, String>>{};
    _keys.forEach((key, perLocale) {
      perLocale.forEach((locale, text) => (out[locale] ??= {})[key] = text);
    });
    return out;
  }

  @override
  Map<String, Map<String, String>> get keys => _byLocale;
}

const _keys = <String, Map<String, String>>{
  // ---- Auth ----
  'Welcome back': {'en_US': 'Welcome back', 'gu_IN': 'પાછા સ્વાગત છે', 'hi_IN': 'वापसी पर स्वागत है'},
  'Login to continue mining': {
    'en_US': 'Login to continue mining',
    'gu_IN': 'માઇનિંગ ચાલુ રાખવા લોગિન કરો',
    'hi_IN': 'माइनिंग जारी रखने के लिए लॉगिन करें',
  },
  'Email': {'en_US': 'Email', 'gu_IN': 'ઈમેલ', 'hi_IN': 'ईमेल'},
  'Password': {'en_US': 'Password', 'gu_IN': 'પાસવર્ડ', 'hi_IN': 'पासवर्ड'},
  'Forgot Password?': {'en_US': 'Forgot Password?', 'gu_IN': 'પાસવર્ડ ભૂલી ગયા?', 'hi_IN': 'पासवर्ड भूल गए?'},
  'Login': {'en_US': 'Login', 'gu_IN': 'લોગિન', 'hi_IN': 'लॉग इन'},
  'or': {'en_US': 'or', 'gu_IN': 'અથવા', 'hi_IN': 'या'},
  'Continue with Google': {
    'en_US': 'Continue with Google',
    'gu_IN': 'Google સાથે ચાલુ રાખો',
    'hi_IN': 'Google से जारी रखें',
  },
  "Don't have an account? Sign Up": {
    'en_US': "Don't have an account? Sign Up",
    'gu_IN': 'એકાઉન્ટ નથી? સાઇન અપ કરો',
    'hi_IN': 'खाता नहीं है? साइन अप करें',
  },
  'Create your account': {
    'en_US': 'Create your account',
    'gu_IN': 'તમારું એકાઉન્ટ બનાવો',
    'hi_IN': 'अपना खाता बनाएं',
  },
  'Start building your mining empire': {
    'en_US': 'Start building your mining empire',
    'gu_IN': 'તમારું માઇનિંગ સામ્રાજ્ય બનાવવાનું શરૂ કરો',
    'hi_IN': 'अपना माइनिंग साम्राज्य बनाना शुरू करें',
  },
  'Username': {'en_US': 'Username', 'gu_IN': 'યુઝરનેમ', 'hi_IN': 'उपयोगकर्ता नाम'},
  'Confirm Password': {'en_US': 'Confirm Password', 'gu_IN': 'પાસવર્ડ કન્ફર્મ કરો', 'hi_IN': 'पासवर्ड की पुष्टि करें'},
  'Referral Code (optional)': {
    'en_US': 'Referral Code (optional)',
    'gu_IN': 'રેફરલ કોડ (વૈકલ્પિક)',
    'hi_IN': 'रेफरल कोड (वैकल्पिक)',
  },
  'Sign Up': {'en_US': 'Sign Up', 'gu_IN': 'સાઇન અપ', 'hi_IN': 'साइन अप'},
  'Apple Sign-In requires an Apple Developer account - see README "Apple Sign-In setup".': {
    'en_US': 'Apple Sign-In requires an Apple Developer account - see README "Apple Sign-In setup".',
    'gu_IN': 'Apple Sign-In મા Apple Developer એકાઉન્ટ જોઈએ - README "Apple Sign-In setup" જુઓ.',
    'hi_IN': 'Apple Sign-In के लिए Apple Developer खाता चाहिए - README "Apple Sign-In setup" देखें।',
  },
  'Under Maintenance': {'en_US': 'Under Maintenance', 'gu_IN': 'મેન્ટેનન્સ ચાલુ છે', 'hi_IN': 'रखरखाव जारी है'},
  'We are making some improvements. Please check back shortly.': {
    'en_US': 'We are making some improvements. Please check back shortly.',
    'gu_IN': 'અમે થોડા સુધારા કરી રહ્યા છીએ. થોડી વારમાં ફરી તપાસો.',
    'hi_IN': 'हम कुछ सुधार कर रहे हैं। थोड़ी देर में फिर देखें।',
  },
  'Update Required': {'en_US': 'Update Required', 'gu_IN': 'અપડેટ જરૂરી છે', 'hi_IN': 'अपडेट आवश्यक है'},
  'A newer version of the app is required to continue.': {
    'en_US': 'A newer version of the app is required to continue.',
    'gu_IN': 'આગળ વધવા એપ્લિકેશનનું નવું વર્ઝન જરૂરી છે.',
    'hi_IN': 'आगे बढ़ने के लिए ऐप का नया वर्शन आवश्यक है।',
  },
  'Update Now': {'en_US': 'Update Now', 'gu_IN': 'હમણાં અપડેટ કરો', 'hi_IN': 'अभी अपडेट करें'},
  'Weekly XP': {'en_US': 'Weekly XP', 'gu_IN': 'સાપ્તાહિક XP', 'hi_IN': 'साप्ताहिक XP'},
  'Monthly XP': {'en_US': 'Monthly XP', 'gu_IN': 'માસિક XP', 'hi_IN': 'मासिक XP'},
  'Already have an account? Login': {
    'en_US': 'Already have an account? Login',
    'gu_IN': 'પહેલેથી એકાઉન્ટ છે? લોગિન કરો',
    'hi_IN': 'पहले से खाता है? लॉगिन करें',
  },
  'A mining session is already active.': {
    'en_US': 'A mining session is already active.',
    'gu_IN': 'એક માઇનિંગ સેશન પહેલેથી ચાલુ છે.',
    'hi_IN': 'एक माइनिंग सेशन पहले से सक्रिय है।',
  },
  'Password reset email sent.': {
    'en_US': 'Password reset email sent.',
    'gu_IN': 'પાસવર્ડ રીસેટ ઈમેલ મોકલાયો.',
    'hi_IN': 'पासवर्ड रीसेट ईमेल भेजा गया।',
  },
  'Could not send reset email. Please try again.': {
    'en_US': 'Could not send reset email. Please try again.',
    'gu_IN': 'રીસેટ ઈમેલ મોકલી શકાયો નહીં. ફરી પ્રયાસ કરો.',
    'hi_IN': 'रीसेट ईमेल नहीं भेजा जा सका। फिर कोशिश करें।',
  },
  'Login failed. Please try again.': {
    'en_US': 'Login failed. Please try again.',
    'gu_IN': 'લોગિન નિષ્ફળ. ફરી પ્રયાસ કરો.',
    'hi_IN': 'लॉगिन विफल। फिर कोशिश करें।',
  },
  'Google Sign-In is not configured yet - see README "Google Sign-In setup".': {
    'en_US': 'Google Sign-In is not configured yet - see README "Google Sign-In setup".',
    'gu_IN': 'Google Sign-In હજુ કન્ફિગર થયું નથી - README "Google Sign-In setup" જુઓ.',
    'hi_IN': 'Google Sign-In अभी कॉन्फ़िगर नहीं है - README "Google Sign-In setup" देखें।',
  },
  'Google sign-in failed. Make sure it is configured in Supabase Auth.': {
    'en_US': 'Google sign-in failed. Make sure it is configured in Supabase Auth.',
    'gu_IN': 'Google સાઇન-ઇન નિષ્ફળ. ખાતરી કરો કે તે Supabase Auth માં કન્ફિગર થયેલું છે.',
    'hi_IN': 'Google साइन-इन विफल। सुनिश्चित करें कि यह Supabase Auth में कॉन्फ़िगर है।',
  },
  'Account created! Check your email, then log in.': {
    'en_US': 'Account created! Check your email, then log in.',
    'gu_IN': 'એકાઉન્ટ બન્યું! તમારો ઈમેલ તપાસો, પછી લોગિન કરો.',
    'hi_IN': 'खाता बन गया! अपना ईमेल जांचें, फिर लॉगिन करें।',
  },
  'Sign up failed. Please try again.': {
    'en_US': 'Sign up failed. Please try again.',
    'gu_IN': 'સાઇન અપ નિષ્ફળ. ફરી પ્રયાસ કરો.',
    'hi_IN': 'साइन अप विफल। फिर कोशिश करें।',
  },
  'Account deletion requests are reviewed by support. Contact us to proceed.': {
    'en_US': 'Account deletion requests are reviewed by support. Contact us to proceed.',
    'gu_IN': 'એકાઉન્ટ ડિલીટ વિનંતીઓ સપોર્ટ દ્વારા સમીક્ષા થાય છે. આગળ વધવા અમારો સંપર્ક કરો.',
    'hi_IN': 'खाता हटाने के अनुरोधों की समीक्षा सपोर्ट टीम करती है। आगे बढ़ने के लिए हमसे संपर्क करें।',
  },
  'Referral code copied!': {
    'en_US': 'Referral code copied!',
    'gu_IN': 'રેફરલ કોડ કૉપિ થયો!',
    'hi_IN': 'रेफरल कोड कॉपी हो गया!',
  },
  'Mission reward claimed!': {
    'en_US': 'Mission reward claimed!',
    'gu_IN': 'મિશન રિવોર્ડ ક્લેઇમ થયો!',
    'hi_IN': 'मिशन रिवॉर्ड क्लेम हो गया!',
  },
  'Mining session started.': {
    'en_US': 'Mining session started.',
    'gu_IN': 'માઇનિંગ સેશન શરૂ થયું.',
    'hi_IN': 'माइनिंग सेशन शुरू हुआ।',
  },
  'Ad not ready yet - try again in a moment.': {
    'en_US': 'Ad not ready yet - try again in a moment.',
    'gu_IN': 'જાહેરાત હજુ તૈયાર નથી - થોડી વારમાં ફરી પ્રયાસ કરો.',
    'hi_IN': 'विज्ञापन अभी तैयार नहीं है - थोड़ी देर में फिर कोशिश करें।',
  },
  '+15 minutes added to your session!': {
    'en_US': '+15 minutes added to your session!',
    'gu_IN': 'તમારા સેશનમાં +૧૫ મિનિટ ઉમેરાઈ!',
    'hi_IN': 'आपके सेशन में +15 मिनट जुड़ गए!',
  },
  'Extra time is not available right now.': {
    'en_US': 'Extra time is not available right now.',
    'gu_IN': 'હાલમાં વધારાનો સમય ઉપલબ્ધ નથી.',
    'hi_IN': 'अभी अतिरिक्त समय उपलब्ध नहीं है।',
  },
  'Payment received - extra time will appear shortly.': {
    'en_US': 'Payment received - extra time will appear shortly.',
    'gu_IN': 'પેમેન્ટ મળ્યું - વધારાનો સમય જલ્દી દેખાશે.',
    'hi_IN': 'भुगतान मिला - अतिरिक्त समय जल्द दिखेगा।',
  },
  'Payment received - points will appear shortly.': {
    'en_US': 'Payment received - points will appear shortly.',
    'gu_IN': 'પેમેન્ટ મળ્યું - પોઈન્ટ જલ્દી દેખાશે.',
    'hi_IN': 'भुगतान मिला - पॉइंट जल्द दिखेंगे।',
  },
  'claimedPoints': {
    'en_US': 'Claimed @value points!',
    'gu_IN': '@value પોઈન્ટ ક્લેઇમ થયા!',
    'hi_IN': '@value पॉइंट क्लेम हुए!',
  },
  'boostActivated': {
    'en_US': '@name activated!',
    'gu_IN': '@name સક્રિય થયું!',
    'hi_IN': '@name सक्रिय हो गया!',
  },
  'couldNotActivateBoost': {
    'en_US': 'Could not activate boost: @error',
    'gu_IN': 'બૂસ્ટ સક્રિય કરી શકાયો નહીં: @error',
    'hi_IN': 'बूस्ट सक्रिय नहीं हो सका: @error',
  },
  'couldNotExtendSession': {
    'en_US': 'Could not extend session: @error',
    'gu_IN': 'સેશન લંબાવી શકાયું નહીં: @error',
    'hi_IN': 'सेशन नहीं बढ़ाया जा सका: @error',
  },
  'minutesAdded': {
    'en_US': '+@value minutes added!',
    'gu_IN': '+@value મિનિટ ઉમેરાઈ!',
    'hi_IN': '+@value मिनट जुड़ गए!',
  },
  'purchaseFailed': {
    'en_US': 'Purchase failed: @error',
    'gu_IN': 'ખરીદી નિષ્ફળ: @error',
    'hi_IN': 'खरीद विफल: @error',
  },
  'pointsAdded': {
    'en_US': '@value coins added!',
    'gu_IN': '@value coins ઉમેરાયા!',
    'hi_IN': '@value coins जुड़ गए!',
  },
  'Watch ad · Claim 2x': {'en_US': 'Watch ad · Claim 2x', 'gu_IN': 'Ad જુઓ · 2x મેળવો', 'hi_IN': 'Ad देखें · 2x पाएं'},
  'claimedNoBonus': {
    'en_US': '@value coins claimed. Daily 2x limit reached - try again tomorrow.',
    'gu_IN': '@value coins મળ્યા. આજની 2x લિમિટ પૂરી - કાલે ફરી ટ્રાય કરો.',
    'hi_IN': '@value coins मिले। आज की 2x लिमिट पूरी - कल फिर कोशिश करें।',
  },
  'Free coins': {'en_US': 'Free coins', 'gu_IN': 'મફત coins', 'hi_IN': 'मुफ़्त coins'},
  'freeCoinsLeft': {
    'en_US': 'Watch a short ad · @left left today',
    'gu_IN': 'નાની ad જુઓ · આજે @left બાકી',
    'hi_IN': 'छोटा ad देखें · आज @left बाकी',
  },
  'Watch a short video': {'en_US': 'Watch a short video', 'gu_IN': 'નાનો વિડિયો જુઓ', 'hi_IN': 'छोटा वीडियो देखें'},
  'freeCoinsLeftShort': {'en_US': '@left left today', 'gu_IN': 'આજે @left બાકી', 'hi_IN': 'आज @left बाकी'},
  'WATCH': {'en_US': 'WATCH', 'gu_IN': 'જુઓ', 'hi_IN': 'देखें'},
  'speedUpButton': {
    'en_US': 'Watch ad · Finish 10 min sooner (@left left today)',
    'gu_IN': 'Ad જુઓ · 10 મિનિટ વહેલું (આજે @left બાકી)',
    'hi_IN': 'Ad देखें · 10 मिनट जल्दी (आज @left बाकी)',
  },
  'speedUpDone': {
    'en_US': 'Mining will finish @value minutes sooner!',
    'gu_IN': 'Mining @value મિનિટ વહેલું પૂરું થશે!',
    'hi_IN': 'Mining @value मिनट जल्दी पूरी होगी!',
  },
  'ad_reward': {'en_US': 'ad reward', 'gu_IN': 'ad ઇનામ', 'hi_IN': 'ad इनाम'},
  // ---- Reminder notifications (ReminderService) ----
  'streakReminderTitle': {
    'en_US': '🔥 Don\'t lose your @days-day streak!',
    'gu_IN': '🔥 તમારી @days દિવસની streak તૂટવા ન દો!',
    'hi_IN': '🔥 अपनी @days दिन की streak मत तोड़ो!',
  },
  'streakStartTitle': {
    'en_US': '🔥 Start your streak today!',
    'gu_IN': '🔥 આજે તમારી streak શરૂ કરો!',
    'hi_IN': '🔥 आज अपनी streak शुरू करो!',
  },
  'streakReminderBody': {
    'en_US': 'Open the app today to keep it going and earn your streak bonus.',
    'gu_IN': 'આજે એપ ખોલો, streak ચાલુ રાખો અને બોનસ મેળવો.',
    'hi_IN': 'आज ऐप खोलें, streak जारी रखें और बोनस पाएं।',
  },
  'streakLastChanceTitle': {
    'en_US': '⏰ Last chance to save your streak!',
    'gu_IN': '⏰ Streak બચાવવાની છેલ્લી તક!',
    'hi_IN': '⏰ Streak बचाने का आखिरी मौका!',
  },
  'streakLastChanceBody': {
    'en_US': 'Your @days-day streak ends at midnight. Open the app now to keep it.',
    'gu_IN': 'તમારી @days દિવસની streak રાતે 12 વાગે તૂટી જશે. હમણાં એપ ખોલો.',
    'hi_IN': 'आपकी @days दिन की streak रात 12 बजे टूट जाएगी। अभी ऐप खोलें।',
  },
  'dailyBonusTitle': {
    'en_US': '🎡 Your daily bonus is ready',
    'gu_IN': '🎡 તમારું આજનું બોનસ તૈયાર છે',
    'hi_IN': '🎡 आपका आज का बोनस तैयार है',
  },
  'dailyBonusBody': {
    'en_US': 'Free spins and free coins are waiting for you.',
    'gu_IN': 'મફત spins અને મફત coins તમારી રાહ જુએ છે.',
    'hi_IN': 'मुफ़्त spins और मुफ़्त coins आपका इंतज़ार कर रहे हैं।',
  },
  'miningDoneTitle': {
    'en_US': '⛏️ Mining complete!',
    'gu_IN': '⛏️ Mining પૂરું થયું!',
    'hi_IN': '⛏️ Mining पूरी हुई!',
  },
  'miningDoneBody': {
    'en_US': 'Your coins are ready - claim them (or watch an ad for 2x).',
    'gu_IN': 'તમારા coins તૈયાર છે - હમણાં મેળવો (અથવા ad જોઈને 2x).',
    'hi_IN': 'आपके coins तैयार हैं - अभी लें (या ad देखकर 2x)।',
  },
  'miningLiveTitle': {
    'en_US': '⛏️ Mining in progress',
    'gu_IN': '⛏️ Mining ચાલુ છે',
    'hi_IN': '⛏️ Mining चल रही है',
  },
  'miningLiveBody': {
    'en_US': 'Your farm is mining at @hashrate TH/s',
    'gu_IN': 'તમારું ફાર્મ @hashrate TH/s પર mining કરે છે',
    'hi_IN': 'आपका फार्म @hashrate TH/s पर mining कर रहा है',
  },
  'missYouTitle': {
    'en_US': '💤 Your farm is waiting',
    'gu_IN': '💤 તમારું ફાર્મ તમારી રાહ જુએ છે',
    'hi_IN': '💤 आपका फार्म आपका इंतज़ार कर रहा है',
  },
  'missYouBody': {
    'en_US': 'Your miners are idle. Start a session and keep earning coins.',
    'gu_IN': 'તમારા miners બંધ પડ્યા છે. Mining શરૂ કરો અને coins કમાતા રહો.',
    'hi_IN': 'आपके miners बंद पड़े हैं। Mining शुरू करें और coins कमाते रहें।',
  },
  'rentalEndingTitle': {
    'en_US': '⏳ @name rental ends tomorrow',
    'gu_IN': '⏳ @name નું ભાડું કાલે પૂરું થાય છે',
    'hi_IN': '⏳ @name का किराया कल खत्म होगा',
  },
  'rentalEndingBody': {
    'en_US': 'Renew it to keep it mining in your farm.',
    'gu_IN': 'ફાર્મમાં mining ચાલુ રાખવા માટે renew કરો.',
    'hi_IN': 'फार्म में mining जारी रखने के लिए renew करें।',
  },
  'Success': {'en_US': 'Success', 'gu_IN': 'સફળ', 'hi_IN': 'सफल'},
  'Oops!': {'en_US': 'Oops!', 'gu_IN': 'અરે!', 'hi_IN': 'अरे!'},
  'Info': {'en_US': 'Info', 'gu_IN': 'માહિતી', 'hi_IN': 'जानकारी'},
  'Something went wrong. Please try again.': {
    'en_US': 'Something went wrong. Please try again.',
    'gu_IN': 'કંઈક ખોટું થયું. ફરી પ્રયત્ન કરો.',
    'hi_IN': 'कुछ गलत हो गया। फिर से कोशिश करें।',
  },
  'All caught up ✨': {'en_US': 'All caught up ✨', 'gu_IN': 'બધું વંચાઈ ગયું ✨', 'hi_IN': 'सब पढ़ लिया ✨'},
  'unreadCount': {'en_US': '@n unread', 'gu_IN': '@n વાંચવાના બાકી', 'hi_IN': '@n पढ़ने बाकी'},
  'just now': {'en_US': 'just now', 'gu_IN': 'હમણાં', 'hi_IN': 'अभी'},
  'minutesAgo': {'en_US': '@nm ago', 'gu_IN': '@n મિનિટ પહેલાં', 'hi_IN': '@n मिनट पहले'},
  'hoursAgo': {'en_US': '@nh ago', 'gu_IN': '@n કલાક પહેલાં', 'hi_IN': '@n घंटे पहले'},
  'daysAgo': {'en_US': '@nd ago', 'gu_IN': '@n દિવસ પહેલાં', 'hi_IN': '@n दिन पहले'},
  'Mark all read': {'en_US': 'Mark all read', 'gu_IN': 'બધું વાંચ્યું', 'hi_IN': 'सब पढ़ लिया'},
  'extraTimeButton': {'en_US': '+60 min @price', 'gu_IN': '+60 મિનિટ @price', 'hi_IN': '+60 मिनट @price'},
  'usernameRules': {
    'en_US': '3-20 characters: letters, numbers, _ or . only',
    'gu_IN': '3-20 અક્ષર: ફક્ત અક્ષરો, અંકો, _ અથવા .',
    'hi_IN': '3-20 अक्षर: केवल अक्षर, अंक, _ या .',
  },
  'AUTO MINING · 24h': {'en_US': 'AUTO MINING · 24h', 'gu_IN': 'AUTO MINING · 24 કલાક', 'hi_IN': 'AUTO MINING · 24 घंटे'},
  'START 24H AUTO MINING': {
    'en_US': 'START 24H AUTO MINING',
    'gu_IN': '24 કલાક AUTO MINING શરૂ કરો',
    'hi_IN': '24 घंटे AUTO MINING शुरू करें',
  },
  '24h Auto Mining ready!': {
    'en_US': '24h Auto Mining ready!',
    'gu_IN': '24 કલાક Auto Mining તૈયાર!',
    'hi_IN': '24 घंटे Auto Mining तैयार!',
  },
  'autoMiningReadyBody': {
    'en_US': 'Your next session runs a full 24 hours. Passes: @n',
    'gu_IN': 'તમારું આગલું session પૂરા 24 કલાક ચાલશે. Passes: @n',
    'hi_IN': 'आपका अगला session पूरे 24 घंटे चलेगा। Passes: @n',
  },
  'How it works': {'en_US': 'How it works', 'gu_IN': 'કેવી રીતે કામ કરે છે', 'hi_IN': 'कैसे काम करता है'},
  'referralYouGet': {
    'en_US': 'You get 24h Auto Mining - your next session runs a full day - as soon as a friend joins with your code.',
    'gu_IN': 'મિત્ર તમારા code થી જોડાય કે તરત તમને 24 કલાક Auto Mining મળે - આગલું session આખો દિવસ ચાલે.',
    'hi_IN': 'दोस्त आपके code से जुड़ते ही आपको 24 घंटे Auto Mining मिलता है - अगला session पूरा दिन चलता है।',
  },
  'referralFriendGets': {
    'en_US': 'Your friend gets 50 coins to start.',
    'gu_IN': 'તમારા મિત્રને શરૂઆતમાં 50 coins મળે.',
    'hi_IN': 'आपके दोस्त को शुरुआत में 50 coins मिलते हैं।',
  },
  'referralStack': {
    'en_US': 'Each friend = one more 24h pass (hold up to 7).',
    'gu_IN': 'દરેક મિત્ર = એક વધુ 24 કલાકનો pass (7 સુધી રાખી શકાય).',
    'hi_IN': 'हर दोस्त = एक और 24 घंटे का pass (7 तक रख सकते हैं)।',
  },
  'referralShareText': {
    'en_US': 'Join me on Virtual Mining Empire! Use my code @code when you sign up and get 50 free coins.',
    'gu_IN': 'Virtual Mining Empire માં જોડાઓ! Signup વખતે મારો code @code નાખો અને 50 મફત coins મેળવો.',
    'hi_IN': 'Virtual Mining Empire से जुड़ें! Signup करते समय मेरा code @code डालें और 50 मुफ़्त coins पाएं।',
  },
  "Have a friend's code?": {'en_US': "Have a friend's code?", 'gu_IN': 'મિત્રનો code છે?', 'hi_IN': 'दोस्त का code है?'},
  'friendCodeHint': {
    'en_US': 'Add it within 48 hours of joining to get 50 free coins.',
    'gu_IN': 'જોડાયાના 48 કલાકમાં નાખો અને 50 મફત coins મેળવો.',
    'hi_IN': 'जुड़ने के 48 घंटे में डालें और 50 मुफ़्त coins पाएं।',
  },
  'Enter code': {'en_US': 'Enter code', 'gu_IN': 'Code નાખો', 'hi_IN': 'Code डालें'},
  'Apply': {'en_US': 'Apply', 'gu_IN': 'લાગુ કરો', 'hi_IN': 'लागू करें'},
  'friendCodeApplied': {
    'en_US': 'Code applied! 50 coins added to your balance.',
    'gu_IN': 'Code લાગુ થયો! 50 coins ઉમેરાયા.',
    'hi_IN': 'Code लागू हो गया! 50 coins जुड़ गए।',
  },
  'Buy Coins': {'en_US': 'Buy Coins', 'gu_IN': 'Coins ખરીદો', 'hi_IN': 'Coins खरीदें'},
  'Get coins': {'en_US': 'Get coins', 'gu_IN': 'Coins મેળવો', 'hi_IN': 'Coins पाएं'},
  'getMoreCoins': {
    'en_US': 'Get @coins more coins',
    'gu_IN': 'બીજા @coins coins મેળવો',
    'hi_IN': 'और @coins coins पाएं',
  },
  'coinsPerDay': {'en_US': '@coins coins/day', 'gu_IN': '@coins coins/દિવસ', 'hi_IN': '@coins coins/दिन'},
  'upgradeCostCoins': {
    'en_US': 'Upgrade cost: @cost coins',
    'gu_IN': 'Upgrade નો ખર્ચ: @cost coins',
    'hi_IN': 'Upgrade का खर्च: @cost coins',
  },
  'Spend coins on miners, farm upgrades and machine upgrades. Coins are virtual and have no cash value.': {
    'en_US': 'Spend coins on miners, farm upgrades and machine upgrades. Coins are virtual and have no cash value.',
    'gu_IN': 'Coins થી miners, farm upgrade અને machine upgrade ખરીદો. Coins વર્ચ્યુઅલ છે, એની કોઈ રોકડ કિંમત નથી.',
    'hi_IN': 'Coins से miners, farm upgrade और machine upgrade खरीदें। Coins वर्चुअल हैं, इनकी कोई नकद कीमत नहीं है।',
  },
  'machineUpgraded': {
    'en_US': '@name upgraded!',
    'gu_IN': '@name અપગ્રેડ થયું!',
    'hi_IN': '@name अपग्रेड हो गया!',
  },

  // ---- Onboarding ----
  'Skip': {'en_US': 'Skip', 'gu_IN': 'સ્કિપ', 'hi_IN': 'छोड़ें'},
  'Get Started': {'en_US': 'Get Started', 'gu_IN': 'શરૂ કરો', 'hi_IN': 'शुरू करें'},
  'Next': {'en_US': 'Next', 'gu_IN': 'આગળ', 'hi_IN': 'अगला'},

  // ---- Bottom nav ----
  'Home': {'en_US': 'Home', 'gu_IN': 'હોમ', 'hi_IN': 'होम'},
  'Mine': {'en_US': 'Mine', 'gu_IN': 'માઇન', 'hi_IN': 'माइन'},
  'Farm': {'en_US': 'Farm', 'gu_IN': 'ફાર્મ', 'hi_IN': 'फार्म'},
  'Rewards': {'en_US': 'Rewards', 'gu_IN': 'રિવોર્ડ્સ', 'hi_IN': 'रिवॉर्ड्स'},
  'Profile': {'en_US': 'Profile', 'gu_IN': 'પ્રોફાઇલ', 'hi_IN': 'प्रोफ़ाइल'},

  // ---- Home ----
  'levelLabel': {'en_US': 'Level @level', 'gu_IN': 'લેવલ @level', 'hi_IN': 'लेवल @level'},
  'Mining Power': {'en_US': 'Mining Power', 'gu_IN': 'માઇનિંગ પાવર', 'hi_IN': 'माइनिंग पावर'},
  'ACTIVE': {'en_US': 'ACTIVE', 'gu_IN': 'સક્રિય', 'hi_IN': 'सक्रिय'},
  'IDLE': {'en_US': 'IDLE', 'gu_IN': 'નિષ્ક્રિય', 'hi_IN': 'निष्क्रिय'},
  'VIEW MINING': {'en_US': 'VIEW MINING', 'gu_IN': 'માઇનિંગ જુઓ', 'hi_IN': 'माइनिंग देखें'},
  'Available Reward': {'en_US': 'Available Reward', 'gu_IN': 'ઉપલબ્ધ રિવોર્ડ', 'hi_IN': 'उपलब्ध रिवॉर्ड'},
  'Pending Reward': {'en_US': 'Pending Reward', 'gu_IN': 'બાકી રિવોર્ડ', 'hi_IN': 'लंबित रिवॉर्ड'},
  'streakDays': {
    'en_US': '@count Day Streak',
    'gu_IN': '@count દિવસનો સ્ટ્રીક',
    'hi_IN': '@count दिन की स्ट्रीक',
  },
  "Today's Missions": {'en_US': "Today's Missions", 'gu_IN': 'આજના મિશન', 'hi_IN': 'आज के मिशन'},
  'No missions yet today.': {
    'en_US': 'No missions yet today.',
    'gu_IN': 'આજે હજુ કોઈ મિશન નથી.',
    'hi_IN': 'आज अभी कोई मिशन नहीं है।',
  },
  'farmLevel': {'en_US': 'Farm Level @level', 'gu_IN': 'ફાર્મ લેવલ @level', 'hi_IN': 'फार्म लेवल @level'},

  // ---- Mining ----
  'Mining': {'en_US': 'Mining', 'gu_IN': 'માઇનિંગ', 'hi_IN': 'माइनिंग'},
  'Active Boosts': {'en_US': 'Active Boosts', 'gu_IN': 'સક્રિય બૂસ્ટ', 'hi_IN': 'सक्रिय बूस्ट'},
  'No active boosts. Watch an ad to get one!': {
    'en_US': 'No active boosts. Watch an ad to get one!',
    'gu_IN': 'કોઈ સક્રિય બૂસ્ટ નથી. એક મેળવવા જાહેરાત જુઓ!',
    'hi_IN': 'कोई सक्रिय बूस्ट नहीं। एक पाने के लिए विज्ञापन देखें!',
  },
  'Watch Ad for Boost': {
    'en_US': 'Watch Ad for Boost',
    'gu_IN': 'બૂસ્ટ માટે જાહેરાત જુઓ',
    'hi_IN': 'बूस्ट के लिए विज्ञापन देखें',
  },
  'Mining History': {'en_US': 'Mining History', 'gu_IN': 'માઇનિંગ ઇતિહાસ', 'hi_IN': 'माइनिंग इतिहास'},
  'No mining sessions yet.': {
    'en_US': 'No mining sessions yet.',
    'gu_IN': 'હજુ કોઈ માઇનિંગ સેશન નથી.',
    'hi_IN': 'अभी कोई माइनिंग सेशन नहीं है।',
  },
  'SESSION COMPLETED 🎉': {
    'en_US': 'SESSION COMPLETED 🎉',
    'gu_IN': 'સેશન પૂર્ણ થયું 🎉',
    'hi_IN': 'सेशन पूरा हुआ 🎉',
  },
  'MINING IN PROGRESS': {'en_US': 'MINING IN PROGRESS', 'gu_IN': 'માઇનિંગ ચાલુ છે', 'hi_IN': 'माइनिंग जारी है'},
  'NO ACTIVE SESSION': {'en_US': 'NO ACTIVE SESSION', 'gu_IN': 'કોઈ સક્રિય સેશન નથી', 'hi_IN': 'कोई सक्रिय सेशन नहीं'},
  'hashrateLabel': {'en_US': 'Hashrate: @value', 'gu_IN': 'હેશરેટ: @value', 'hi_IN': 'हैशरेट: @value'},
  'miningViaFarm': {
    'en_US': 'Mining via @farm',
    'gu_IN': '@farm દ્વારા માઇનિંગ',
    'hi_IN': '@farm के ज़रिए माइनिंग',
  },
  'START MINING': {'en_US': 'START MINING', 'gu_IN': 'માઇનિંગ શરૂ કરો', 'hi_IN': 'माइनिंग शुरू करें'},
  'MINING...': {'en_US': 'MINING...', 'gu_IN': 'માઇનિંગ ચાલુ...', 'hi_IN': 'माइनिंग हो रही है...'},
  'CLAIM REWARD': {'en_US': 'CLAIM REWARD', 'gu_IN': 'રિવોર્ડ ક્લેઇમ કરો', 'hi_IN': 'रिवॉर्ड क्लेम करें'},
  'or keep mining a little longer': {
    'en_US': 'or keep mining a little longer',
    'gu_IN': 'અથવા થોડું વધુ માઇનિંગ ચાલુ રાખો',
    'hi_IN': 'या थोड़ी देर और माइनिंग करें',
  },
  '+15 min free': {'en_US': '+15 min free', 'gu_IN': '+૧૫ મિનિટ મફત', 'hi_IN': '+15 मिनट मुफ्त'},

  // ---- Farm ----
  'Farm Level': {'en_US': 'Farm Level', 'gu_IN': 'ફાર્મ લેવલ', 'hi_IN': 'फार्म लेवल'},
  'Upgrade Farm': {'en_US': 'Upgrade Farm', 'gu_IN': 'ફાર્મ અપગ્રેડ કરો', 'hi_IN': 'फार्म अपग्रेड करें'},
  'My Machines': {'en_US': 'My Machines', 'gu_IN': 'મારા મશીનો', 'hi_IN': 'मेरी मशीनें'},
  'View all': {'en_US': 'View all', 'gu_IN': 'બધું જુઓ', 'hi_IN': 'सभी देखें'},
  'No machines yet. Complete onboarding to get a starter machine.': {
    'en_US': 'No machines yet. Complete onboarding to get a starter machine.',
    'gu_IN': 'હજુ કોઈ મશીન નથી. સ્ટાર્ટર મશીન મેળવવા ઓનબોર્ડિંગ પૂર્ણ કરો.',
    'hi_IN': 'अभी कोई मशीन नहीं। स्टार्टर मशीन पाने के लिए ऑनबोर्डिंग पूरी करें।',
  },
  'Available Farm Types': {
    'en_US': 'Available Farm Types',
    'gu_IN': 'ઉપલબ્ધ ફાર્મ પ્રકારો',
    'hi_IN': 'उपलब्ध फार्म प्रकार',
  },
  'farmLevelCapacity': {
    'en_US': 'Level @level • Capacity @capacity',
    'gu_IN': 'લેવલ @level • ક્ષમતા @capacity',
    'hi_IN': 'लेवल @level • क्षमता @capacity',
  },
  'multiplierLabel': {'en_US': 'Multiplier x@value', 'gu_IN': 'ગુણક x@value', 'hi_IN': 'गुणक x@value'},
  'estRewardPerHour': {
    'en_US': '≈ @value points/hour at your current hashrate',
    'gu_IN': '≈ @value પોઈન્ટ/કલાક તમારા હાલના હેશરેટ પર',
    'hi_IN': '≈ @value पॉइंट/घंटा आपकी मौजूदा हैशरेट पर',
  },
  'upgradeFarmCost': {
    'en_US': 'Upgrade Farm • @cost pts',
    'gu_IN': 'ફાર્મ અપગ્રેડ કરો • @cost પોઈન્ટ',
    'hi_IN': 'फार्म अपग्रेड करें • @cost पॉइंट',
  },
  'payWithPoints': {
    'en_US': 'Pay @cost Coins',
    'gu_IN': '@cost coins થી ચૂકવો',
    'hi_IN': '@cost coins से भुगतान करें',
  },
  'payWithMoney': {
    'en_US': 'Pay ₹@price',
    'gu_IN': '₹@price ચૂકવો',
    'hi_IN': '₹@price का भुगतान करें',
  },
  'Payment received - your upgrade will apply shortly.': {
    'en_US': 'Payment received - your upgrade will apply shortly.',
    'gu_IN': 'પેમેન્ટ મળ્યું - તમારું અપગ્રેડ જલ્દી લાગુ થશે.',
    'hi_IN': 'भुगतान मिला - आपका अपग्रेड जल्द लागू होगा।',
  },
  'machineLevelHashrate': {
    'en_US': 'Level @level • @hashrate TH/s',
    'gu_IN': 'લેવલ @level • @hashrate TH/s',
    'hi_IN': 'लेवल @level • @hashrate TH/s',
  },
  'unlocksLevel': {
    'en_US': 'Unlocks Lv.@level',
    'gu_IN': 'લેવલ @level પર અનલોક',
    'hi_IN': 'लेवल @level पर अनलॉक',
  },
  'Not Enough Points': {'en_US': 'Not Enough Points', 'gu_IN': 'પૂરતા પોઈન્ટ નથી', 'hi_IN': 'पर्याप्त पॉइंट नहीं हैं'},
  'notEnoughPointsBody': {
    'en_US': 'Upgrading to Level @level costs @cost coins.\n\nYou have @balance coins - @shortfall more needed.',
    'gu_IN': 'લેવલ @level પર અપગ્રેડ કરવા @cost coins લાગે છે.\n\nતમારી પાસે @balance coins છે - @shortfall વધુ જોઈએ.',
    'hi_IN': 'लेवल @level पर अपग्रेड करने में @cost coins लगते हैं।\n\nआपके पास @balance coins हैं - @shortfall और चाहिए।',
  },
  'Cancel': {'en_US': 'Cancel', 'gu_IN': 'રદ કરો', 'hi_IN': 'रद्द करें'},
  'Exit': {'en_US': 'Exit', 'gu_IN': 'બહાર નીકળો', 'hi_IN': 'बाहर निकलें'},
  'pressBackAgainToExit': {
    'en_US': 'Press back again to exit',
    'gu_IN': 'બહાર નીકળવા ફરી back દબાવો',
    'hi_IN': 'बाहर निकलने के लिए फिर से back दबाएं',
  },
  'exitAppTitle': {'en_US': 'Exit app?', 'gu_IN': 'એપ બંધ કરવી છે?', 'hi_IN': 'ऐप बंद करें?'},
  'exitAppMessage': {
    'en_US': 'Your mining keeps running while the app is closed.',
    'gu_IN': 'એપ બંધ હોય ત્યારે પણ તમારું mining ચાલુ રહેશે.',
    'hi_IN': 'ऐप बंद होने पर भी आपकी mining चालू रहेगी।',
  },
  'Delete': {'en_US': 'Delete', 'gu_IN': 'ડિલીટ કરો', 'hi_IN': 'हटाएं'},
  'Ad privacy choices': {'en_US': 'Ad privacy choices', 'gu_IN': 'Ads ની પ્રાઇવસી પસંદગી', 'hi_IN': 'Ads की प्राइवेसी पसंद'},
  'Delete your account?': {
    'en_US': 'Delete your account?',
    'gu_IN': 'તમારું એકાઉન્ટ ડિલીટ કરવું છે?',
    'hi_IN': 'क्या आप अपना खाता हटाना चाहते हैं?',
  },
  'deleteAccountWarning': {
    'en_US':
        'This permanently deletes your account, farm, miners, coins and all progress. Active rentals and purchases are lost too. This cannot be undone.',
    'gu_IN':
        'આનાથી તમારું એકાઉન્ટ, ફાર્મ, માઇનર, coins અને બધી પ્રગતિ કાયમ માટે ડિલીટ થઈ જશે. ચાલુ ભાડાના માઇનર અને ખરીદીઓ પણ જતી રહેશે. આ પાછું નહીં લાવી શકાય.',
    'hi_IN':
        'इससे आपका खाता, फार्म, माइनर, coins और सारी प्रगति हमेशा के लिए हट जाएगी। चालू किराए के माइनर और खरीदारी भी चली जाएगी। इसे वापस नहीं लाया जा सकता।',
  },
  'Your account has been deleted.': {
    'en_US': 'Your account has been deleted.',
    'gu_IN': 'તમારું એકાઉન્ટ ડિલીટ થઈ ગયું છે.',
    'hi_IN': 'आपका खाता हटा दिया गया है।',
  },
  'couldNotDeleteAccount': {
    'en_US': 'Could not delete your account: @error',
    'gu_IN': 'એકાઉન્ટ ડિલીટ ન થઈ શક્યું: @error',
    'hi_IN': 'खाता नहीं हटाया जा सका: @error',
  },
  'Buy Points': {'en_US': 'Buy Points', 'gu_IN': 'પોઈન્ટ ખરીદો', 'hi_IN': 'पॉइंट खरीदें'},
  'upgradeToLevel': {
    'en_US': 'Upgrade to Level @level?',
    'gu_IN': 'લેવલ @level પર અપગ્રેડ કરવું છે?',
    'hi_IN': 'लेवल @level पर अपग्रेड करें?',
  },
  'upgradeConfirmBody': {
    'en_US': 'This costs @cost coins.\n\nBalance now: @before\nBalance after: @after',
    'gu_IN': 'આના માટે @cost coins લાગશે.\n\nહાલનું બેલેન્સ: @before\nપછીનું બેલેન્સ: @after',
    'hi_IN': 'इसके लिए @cost coins लगेंगे।\n\nअभी बैलेंस: @before\nबाद में बैलेंस: @after',
  },
  'Upgrade': {'en_US': 'Upgrade', 'gu_IN': 'અપગ્રેડ', 'hi_IN': 'अपग्रेड'},
  'Farm upgraded!': {'en_US': 'Farm upgraded!', 'gu_IN': 'ફાર્મ અપગ્રેડ થયું!', 'hi_IN': 'फार्म अपग्रेड हो गया!'},

  // ---- Rewards / Store ----
  'Available Balance': {'en_US': 'Available Balance', 'gu_IN': 'ઉપલબ્ધ બેલેન્સ', 'hi_IN': 'उपलब्ध बैलेंस'},
  'Pending Balance': {'en_US': 'Pending Balance', 'gu_IN': 'બાકી બેલેન્સ', 'hi_IN': 'लंबित बैलेंस'},
  "Today's Rewards": {'en_US': "Today's Rewards", 'gu_IN': 'આજના રિવોર્ડ', 'hi_IN': 'आज के रिवॉर्ड'},
  'Total Earned': {'en_US': 'Total Earned', 'gu_IN': 'કુલ કમાણી', 'hi_IN': 'कुल कमाई'},
  'Reward History': {'en_US': 'Reward History', 'gu_IN': 'રિવોર્ડ ઇતિહાસ', 'hi_IN': 'रिवॉर्ड इतिहास'},
  'No rewards yet. Start mining!': {
    'en_US': 'No rewards yet. Start mining!',
    'gu_IN': 'હજુ કોઈ રિવોર્ડ નથી. માઇનિંગ શરૂ કરો!',
    'hi_IN': 'अभी कोई रिवॉर्ड नहीं। माइनिंग शुरू करें!',
  },
  'Status': {'en_US': 'Status', 'gu_IN': 'સ્ટેટસ', 'hi_IN': 'स्थिति'},
  'Source': {'en_US': 'Source', 'gu_IN': 'સ્ત્રોત', 'hi_IN': 'स्रोत'},
  'Date': {'en_US': 'Date', 'gu_IN': 'તારીખ', 'hi_IN': 'तारीख'},
  'Reference ID': {'en_US': 'Reference ID', 'gu_IN': 'સંદર્ભ ID', 'hi_IN': 'संदर्भ ID'},
  'No packages available right now.': {
    'en_US': 'No packages available right now.',
    'gu_IN': 'હાલમાં કોઈ પેકેજ ઉપલબ્ધ નથી.',
    'hi_IN': 'अभी कोई पैकेज उपलब्ध नहीं है।',
  },
  'Razorpay is not configured yet - see README "Razorpay setup". Purchases will fail until it is.': {
    'en_US': 'Razorpay is not configured yet - see README "Razorpay setup". Purchases will fail until it is.',
    'gu_IN': 'Razorpay હજુ કન્ફિગર થયું નથી - README "Razorpay setup" જુઓ. જ્યાં સુધી નહીં થાય ત્યાં સુધી ખરીદી નિષ્ફળ જશે.',
    'hi_IN': 'Razorpay अभी कॉन्फ़िगर नहीं है - README "Razorpay setup" देखें। जब तक नहीं होता, खरीदारी विफल रहेगी।',
  },
  'Points spend on machine and farm upgrades just like mining rewards.': {
    'en_US': 'Points spend on machine and farm upgrades just like mining rewards.',
    'gu_IN': 'પોઈન્ટ મશીન અને ફાર્મ અપગ્રેડ પર માઇનિંગ રિવોર્ડની જેમ જ વપરાય છે.',
    'hi_IN': 'पॉइंट मशीन और फार्म अपग्रेड पर माइनिंग रिवॉर्ड की तरह ही खर्च होते हैं।',
  },
  'pointsAmount': {'en_US': '@value points', 'gu_IN': '@value પોઈન્ટ', 'hi_IN': '@value पॉइंट'},

  // ---- Machine ----
  'Machine Details': {'en_US': 'Machine Details', 'gu_IN': 'મશીન વિગતો', 'hi_IN': 'मशीन विवरण'},
  'This machine could not be found.': {
    'en_US': 'This machine could not be found.',
    'gu_IN': 'આ મશીન મળ્યું નથી.',
    'hi_IN': 'यह मशीन नहीं मिली।',
  },
  'Go Back': {'en_US': 'Go Back', 'gu_IN': 'પાછા જાઓ', 'hi_IN': 'वापस जाएं'},
  'Hashrate': {'en_US': 'Hashrate', 'gu_IN': 'હેશરેટ', 'hi_IN': 'हैशरेट'},
  'Efficiency': {'en_US': 'Efficiency', 'gu_IN': 'કાર્યક્ષમતા', 'hi_IN': 'दक्षता'},
  'About this machine': {'en_US': 'About this machine', 'gu_IN': 'આ મશીન વિશે', 'hi_IN': 'इस मशीन के बारे में'},
  'This machine has reached its maximum level.': {
    'en_US': 'This machine has reached its maximum level.',
    'gu_IN': 'આ મશીન તેના મહત્તમ લેવલ પર પહોંચી ગયું છે.',
    'hi_IN': 'यह मशीन अपने अधिकतम स्तर पर पहुंच गई है।',
  },
  'UPGRADE': {'en_US': 'UPGRADE', 'gu_IN': 'અપગ્રેડ', 'hi_IN': 'अपग्रेड'},
  'No machines yet.': {'en_US': 'No machines yet.', 'gu_IN': 'હજુ કોઈ મશીન નથી.', 'hi_IN': 'अभी कोई मशीन नहीं।'},
  'machineListStats': {
    'en_US': 'Level @level • @hashrate TH/s • @efficiency% eff.',
    'gu_IN': 'લેવલ @level • @hashrate TH/s • @efficiency% કાર્યક્ષમતા',
    'hi_IN': 'लेवल @level • @hashrate TH/s • @efficiency% दक्षता',
  },
  'machineRigLevel': {
    'en_US': '@rig • Level @level / @maxLevel',
    'gu_IN': '@rig • લેવલ @level / @maxLevel',
    'hi_IN': '@rig • लेवल @level / @maxLevel',
  },
  'Advanced Rig': {'en_US': 'Advanced Rig', 'gu_IN': 'એડવાન્સ્ડ રિગ', 'hi_IN': 'एडवांस्ड रिग'},
  'Standard Rig': {'en_US': 'Standard Rig', 'gu_IN': 'સ્ટાન્ડર્ડ રિગ', 'hi_IN': 'स्टैंडर्ड रिग'},

  // ---- Profile ----
  'Level': {'en_US': 'Level', 'gu_IN': 'લેવલ', 'hi_IN': 'लेवल'},
  'XP': {'en_US': 'XP', 'gu_IN': 'XP', 'hi_IN': 'XP'},
  'Streak': {'en_US': 'Streak', 'gu_IN': 'સ્ટ્રીક', 'hi_IN': 'स्ट्रीक'},
  'Referrals': {'en_US': 'Referrals', 'gu_IN': 'રેફરલ', 'hi_IN': 'रेफरल'},
  'achievementsCount': {
    'en_US': 'Achievements (@count)',
    'gu_IN': 'સિદ્ધિઓ (@count)',
    'hi_IN': 'उपलब्धियां (@count)',
  },
  'Referral Program': {'en_US': 'Referral Program', 'gu_IN': 'રેફરલ પ્રોગ્રામ', 'hi_IN': 'रेफरल प्रोग्राम'},
  'Leaderboard': {'en_US': 'Leaderboard', 'gu_IN': 'લીડરબોર્ડ', 'hi_IN': 'लीडरबोर्ड'},
  'Settings': {'en_US': 'Settings', 'gu_IN': 'સેટિંગ્સ', 'hi_IN': 'सेटिंग्स'},
  'Logout': {'en_US': 'Logout', 'gu_IN': 'લોગઆઉટ', 'hi_IN': 'लॉगआउट'},

  // ---- Settings ----
  'Notifications': {'en_US': 'Notifications', 'gu_IN': 'નોટિફિકેશન', 'hi_IN': 'सूचनाएं'},
  'Sound': {'en_US': 'Sound', 'gu_IN': 'સાઉન્ડ', 'hi_IN': 'ध्वनि'},
  'Haptic Feedback': {'en_US': 'Haptic Feedback', 'gu_IN': 'હેપ્ટિક ફીડબેક', 'hi_IN': 'हैप्टिक फीडबैक'},
  'Language': {'en_US': 'Language', 'gu_IN': 'ભાષા', 'hi_IN': 'भाषा'},
  'Dark Theme': {'en_US': 'Dark Theme', 'gu_IN': 'ડાર્ક થીમ', 'hi_IN': 'डार्क थीम'},
  'Privacy Policy': {'en_US': 'Privacy Policy', 'gu_IN': 'પ્રાઇવસી પોલિસી', 'hi_IN': 'गोपनीयता नीति'},
  'Terms of Service': {'en_US': 'Terms of Service', 'gu_IN': 'સેવાની શરતો', 'hi_IN': 'सेवा की शर्तें'},
  'Help & Support': {'en_US': 'Help & Support', 'gu_IN': 'મદદ અને સપોર્ટ', 'hi_IN': 'सहायता और समर्थन'},
  'Delete Account': {'en_US': 'Delete Account', 'gu_IN': 'એકાઉન્ટ ડિલીટ કરો', 'hi_IN': 'खाता हटाएं'},
  'versionLabel': {'en_US': 'Version @value', 'gu_IN': 'વર્ઝન @value', 'hi_IN': 'वर्शन @value'},

  // ---- Referral ----
  'Invite Friends': {'en_US': 'Invite Friends', 'gu_IN': 'મિત્રોને આમંત્રિત કરો', 'hi_IN': 'दोस्तों को आमंत्रित करें'},
  'Your Referral Code': {'en_US': 'Your Referral Code', 'gu_IN': 'તમારો રેફરલ કોડ', 'hi_IN': 'आपका रेफरल कोड'},
  'Copy': {'en_US': 'Copy', 'gu_IN': 'કૉપિ કરો', 'hi_IN': 'कॉपी करें'},
  'Share': {'en_US': 'Share', 'gu_IN': 'શેર કરો', 'hi_IN': 'शेयर करें'},
  'Total Invites': {'en_US': 'Total Invites', 'gu_IN': 'કુલ આમંત્રણો', 'hi_IN': 'कुल आमंत्रण'},
  'Active Referrals': {'en_US': 'Active Referrals', 'gu_IN': 'સક્રિય રેફરલ', 'hi_IN': 'सक्रिय रेफरल'},
  'Referral Activity': {'en_US': 'Referral Activity', 'gu_IN': 'રેફરલ પ્રવૃત્તિ', 'hi_IN': 'रेफरल गतिविधि'},
  'No referrals yet. Share your code!': {
    'en_US': 'No referrals yet. Share your code!',
    'gu_IN': 'હજુ કોઈ રેફરલ નથી. તમારો કોડ શેર કરો!',
    'hi_IN': 'अभी कोई रेफरल नहीं। अपना कोड शेयर करें!',
  },

  // ---- Other screen titles / empty states ----
  'Achievements': {'en_US': 'Achievements', 'gu_IN': 'સિદ્ધિઓ', 'hi_IN': 'उपलब्धियां'},
  'No achievements yet.': {
    'en_US': 'No achievements yet.',
    'gu_IN': 'હજુ કોઈ સિદ્ધિ નથી.',
    'hi_IN': 'अभी कोई उपलब्धि नहीं।',
  },
  'No missions today. Check back tomorrow!': {
    'en_US': 'No missions today. Check back tomorrow!',
    'gu_IN': 'આજે કોઈ મિશન નથી. કાલે ફરી તપાસો!',
    'hi_IN': 'आज कोई मिशन नहीं। कल फिर देखें!',
  },
  'Leaderboard is empty.': {
    'en_US': 'Leaderboard is empty.',
    'gu_IN': 'લીડરબોર્ડ ખાલી છે.',
    'hi_IN': 'लीडरबोर्ड खाली है।',
  },
  'No notifications yet.': {
    'en_US': 'No notifications yet.',
    'gu_IN': 'હજુ કોઈ નોટિફિકેશન નથી.',
    'hi_IN': 'अभी कोई सूचना नहीं।',
  },
  'Milestones': {'en_US': 'Milestones', 'gu_IN': 'સીમાચિહ્નો', 'hi_IN': 'मील के पत्थर'},

  // ---- Common ----
  'Retry': {'en_US': 'Retry', 'gu_IN': 'ફરી પ્રયાસ કરો', 'hi_IN': 'पुनः प्रयास करें'},
  "Couldn't load this. Check your connection and try again.": {
    'en_US': "Couldn't load this. Check your connection and try again.",
    'gu_IN': 'આ લોડ થઈ શક્યું નહીં. તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.',
    'hi_IN': 'यह लोड नहीं हो सका। अपना कनेक्शन जांचें और फिर कोशिश करें।',
  },

  // ---- Dynamic lookups: reward_transactions.type / .status, referrals.status ----
  'mining': {'en_US': 'mining', 'gu_IN': 'માઇનિંગ', 'hi_IN': 'माइनिंग'},
  'mission': {'en_US': 'mission', 'gu_IN': 'મિશન', 'hi_IN': 'मिशन'},
  'streak': {'en_US': 'streak', 'gu_IN': 'સ્ટ્રીક', 'hi_IN': 'स्ट्रीक'},
  'level_up': {'en_US': 'level up', 'gu_IN': 'લેવલ અપ', 'hi_IN': 'लेवल अप'},
  'streakBonusToast': {
    'en_US': '🔥 Day @days streak! +@coins coins · +@xp XP',
    'gu_IN': '🔥 Streak દિવસ @days! +@coins coins · +@xp XP',
    'hi_IN': '🔥 Streak दिन @days! +@coins coins · +@xp XP',
  },
  'referral': {'en_US': 'referral', 'gu_IN': 'રેફરલ', 'hi_IN': 'रेफरल'},
  'achievement': {'en_US': 'achievement', 'gu_IN': 'સિદ્ધિ', 'hi_IN': 'उपलब्धि'},
  'boost': {'en_US': 'boost', 'gu_IN': 'બૂસ્ટ', 'hi_IN': 'बूस्ट'},
  'adjustment': {'en_US': 'adjustment', 'gu_IN': 'ગોઠવણ', 'hi_IN': 'समायोजन'},
  'purchase': {'en_US': 'purchase', 'gu_IN': 'ખરીદી', 'hi_IN': 'खरीद'},
  'pending': {'en_US': 'pending', 'gu_IN': 'બાકી', 'hi_IN': 'लंबित'},
  'active': {'en_US': 'active', 'gu_IN': 'સક્રિય', 'hi_IN': 'सक्रिय'},
  'completed': {'en_US': 'completed', 'gu_IN': 'પૂર્ણ', 'hi_IN': 'पूर्ण'},
  'succeeded': {'en_US': 'succeeded', 'gu_IN': 'સફળ', 'hi_IN': 'सफल'},
  'failed': {'en_US': 'failed', 'gu_IN': 'નિષ્ફળ', 'hi_IN': 'असफल'},
  'refunded': {'en_US': 'refunded', 'gu_IN': 'રિફંડ થયું', 'hi_IN': 'रिफंड हुआ'},

  // ---- Dashboard / Mining Farm store / Spin ----
  'Dashboard': {'en_US': 'Dashboard', 'gu_IN': 'ડેશબોર્ડ', 'hi_IN': 'डैशबोर्ड'},
  'Total Balance': {'en_US': 'Total Balance', 'gu_IN': 'કુલ બેલેન્સ', 'hi_IN': 'कुल बैलेंस'},
  'Mining Farm': {'en_US': 'Mining Farm', 'gu_IN': 'માઇનિંગ ફાર્મ', 'hi_IN': 'माइनिंग फार्म'},
  'Available Miners': {'en_US': 'Available Miners', 'gu_IN': 'ઉપલબ્ધ માઇનર્સ', 'hi_IN': 'उपलब्ध माइनर्स'},
  'Buy Now': {'en_US': 'Buy Now', 'gu_IN': 'હમણાં ખરીદો', 'hi_IN': 'अभी खरीदें'},
  'Build your own virtual mining farm': {
    'en_US': 'Build your own virtual mining farm',
    'gu_IN': 'તમારું પોતાનું વર્ચ્યુઅલ માઇનિંગ ફાર્મ બનાવો',
    'hi_IN': 'अपना खुद का वर्चुअल माइनिंग फार्म बनाएं',
  },
  'Grow your virtual mining farm': {
    'en_US': 'Grow your virtual mining farm',
    'gu_IN': 'તમારું વર્ચ્યુઅલ માઇનિંગ ફાર્મ મોટું કરો',
    'hi_IN': 'अपना वर्चुअल माइनिंग फार्म बढ़ाएं',
  },
  'Add more miners': {'en_US': 'Add more miners', 'gu_IN': 'વધુ માઇનર ઉમેરો', 'hi_IN': 'और माइनर जोड़ें'},
  'Create Mining Farm': {'en_US': 'Create Mining Farm', 'gu_IN': 'માઇનિંગ ફાર્મ બનાવો', 'hi_IN': 'माइनिंग फार्म बनाएं'},
  'Daily Spin': {'en_US': 'Daily Spin', 'gu_IN': 'દૈનિક સ્પિન', 'hi_IN': 'दैनिक स्पिन'},
  'Fortune Wheel': {'en_US': 'Fortune Wheel', 'gu_IN': 'ફોર્ચ્યુન વ્હીલ', 'hi_IN': 'फॉर्च्यून व्हील'},
  'Spin the Wheel': {'en_US': 'Spin the Wheel', 'gu_IN': 'વ્હીલ ફેરવો', 'hi_IN': 'व्हील घुमाएं'},
  'Score Table': {'en_US': 'Score Table', 'gu_IN': 'સ્કોર ટેબલ', 'hi_IN': 'स्कोर टेबल'},
  'Better luck next time!': {'en_US': 'Better luck next time!', 'gu_IN': 'આગલી વખતે નસીબ સાથ આપશે!', 'hi_IN': 'अगली बार किस्मत साथ देगी!'},
  'spinWon': {'en_US': 'You won @coins coins!', 'gu_IN': 'તમે @coins કોઇન જીત્યા!', 'hi_IN': 'आपने @coins कॉइन जीते!'},
  'freeSpinsLeft': {
    'en_US': '@count free spins left today',
    'gu_IN': 'આજે @count ફ્રી સ્પિન બાકી',
    'hi_IN': 'आज @count फ्री स्पिन बाकी',
  },
  'adSpinsLeft': {
    'en_US': 'Watch ad for a spin (@count left)',
    'gu_IN': 'સ્પિન માટે એડ જુઓ (@count બાકી)',
    'hi_IN': 'स्पिन के लिए विज्ञापन देखें (@count बाकी)',
  },
  'coinsAmount': {'en_US': '@coins coins', 'gu_IN': '@coins કોઇન', 'hi_IN': '@coins कॉइन'},
  'coinsAmountPrecise': {'en_US': '@coins coins', 'gu_IN': '@coins કોઇન', 'hi_IN': '@coins कॉइन'},
  'coinBalance': {'en_US': 'Your coins: @coins', 'gu_IN': 'તમારા કોઇન: @coins', 'hi_IN': 'आपके कॉइन: @coins'},
  'categoryMiningMachine': {
    'en_US': '@category mining machine',
    'gu_IN': '@category માઇનિંગ મશીન',
    'hi_IN': '@category माइनिंग मशीन',
  },
  'payRupees': {'en_US': 'Pay ₹@price', 'gu_IN': '₹@price ચૂકવો', 'hi_IN': '₹@price का भुगतान करें'},
  'payCoins': {'en_US': 'Pay @coins coins', 'gu_IN': '@coins કોઇન ચૂકવો', 'hi_IN': '@coins कॉइन से भुगतान करें'},
  'perDay': {'en_US': '₹@price/day', 'gu_IN': '₹@price/દિવસ', 'hi_IN': '₹@price/दिन'},
  'fromCoins': {'en_US': 'From @price coins', 'gu_IN': '@price coins થી', 'hi_IN': '@price coins से'},
  'minerRented': {
    'en_US': '@name added to your farm!',
    'gu_IN': '@name તમારા ફાર્મમાં ઉમેરાયું!',
    'hi_IN': '@name आपके फार्म में जोड़ा गया!',
  },
  'myMachinesCount': {'en_US': 'My machines: @count', 'gu_IN': 'મારા મશીન: @count', 'hi_IN': 'मेरी मशीनें: @count'},
  'machinesInFarm': {'en_US': '@count machines running', 'gu_IN': '@count મશીન ચાલુ', 'hi_IN': '@count मशीनें चालू'},
  'rentalExpiresIn': {'en_US': 'Rental ends @date', 'gu_IN': 'ભાડું @date એ પૂરું', 'hi_IN': 'किराया @date को खत्म'},
  'daysLeft': {'en_US': '@n days left', 'gu_IN': '@n દિવસ બાકી', 'hi_IN': '@n दिन बाकी'},
  '1 day left': {'en_US': '1 day left', 'gu_IN': '1 દિવસ બાકી', 'hi_IN': '1 दिन बाकी'},
  'hoursLeft': {'en_US': '@n hours left', 'gu_IN': '@n કલાક બાકી', 'hi_IN': '@n घंटे बाकी'},
  'Ends in under an hour': {
    'en_US': 'Ends in under an hour',
    'gu_IN': '1 કલાકથી ઓછું બાકી',
    'hi_IN': '1 घंटे से कम बाकी',
  },
  'endsOn': {'en_US': 'Ends @date', 'gu_IN': '@date એ પૂરું', 'hi_IN': '@date को खत्म'},
  'Rental': {'en_US': 'Rental', 'gu_IN': 'ભાડું', 'hi_IN': 'किराया'},
  'Rental expired': {'en_US': 'Rental expired', 'gu_IN': 'ભાડું પૂરું થયું', 'hi_IN': 'किराया खत्म'},
  'EXPIRED': {'en_US': 'EXPIRED', 'gu_IN': 'પૂરું', 'hi_IN': 'समाप्त'},
  'MINING': {'en_US': 'MINING', 'gu_IN': 'માઇનિંગ', 'hi_IN': 'माइनिंग'},
  'NOT SELECTED': {'en_US': 'NOT SELECTED', 'gu_IN': 'પસંદ નથી', 'hi_IN': 'चुना नहीं'},
  'Not in this session': {
    'en_US': 'Not in this session',
    'gu_IN': 'આ સેશનમાં નથી',
    'hi_IN': 'इस सेशन में नहीं',
  },
  'Choose miners': {'en_US': 'Choose miners', 'gu_IN': 'માઇનર પસંદ કરો', 'hi_IN': 'माइनर चुनें'},
  'Pick the miners this session will run on.': {
    'en_US': 'Pick the miners this session will run on.',
    'gu_IN': 'આ સેશનમાં કયા માઇનર ચલાવવા છે તે પસંદ કરો.',
    'hi_IN': 'इस सेशन में कौन से माइनर चलाने हैं, चुनें।',
  },
  'Select all': {'en_US': 'Select all', 'gu_IN': 'બધા પસંદ કરો', 'hi_IN': 'सभी चुनें'},
  'Clear all': {'en_US': 'Clear all', 'gu_IN': 'બધા હટાવો', 'hi_IN': 'सभी हटाएं'},
  'Machine': {'en_US': 'Machine', 'gu_IN': 'મશીન', 'hi_IN': 'मशीन'},
  'minersSelected': {
    'en_US': '@count of @total selected',
    'gu_IN': '@total માંથી @count પસંદ',
    'hi_IN': '@total में से @count चुने',
  },
  'NEXT SESSION': {'en_US': 'NEXT SESSION', 'gu_IN': 'આગલું સેશન', 'hi_IN': 'अगला सेशन'},
  'Starts mining next session': {
    'en_US': 'Starts mining next session',
    'gu_IN': 'આગલા સેશનથી માઇનિંગ શરૂ',
    'hi_IN': 'अगले सेशन से माइनिंग शुरू',
  },
  'Start mining to use it': {
    'en_US': 'Start mining to use it',
    'gu_IN': 'વાપરવા માટે માઇનિંગ શરૂ કરો',
    'hi_IN': 'इस्तेमाल के लिए माइनिंग शुरू करें',
  },
  'Renew': {'en_US': 'Renew', 'gu_IN': 'રિન્યૂ કરો', 'hi_IN': 'रिन्यू करें'},
  'Owned': {'en_US': 'Owned', 'gu_IN': 'તમારું', 'hi_IN': 'आपका'},
  'Buy Again': {'en_US': 'Buy Again', 'gu_IN': 'ફરી ખરીદો', 'hi_IN': 'फिर से खरीदें'},
  'Mining in your farm': {
    'en_US': 'Mining in your farm',
    'gu_IN': 'તમારા ફાર્મમાં માઇનિંગ ચાલુ',
    'hi_IN': 'आपके फार्म में माइनिंग जारी',
  },
  'Payment received - your miner will be added shortly.': {
    'en_US': 'Payment received - your miner will be added shortly.',
    'gu_IN': 'પેમેન્ટ મળ્યું - તમારું માઇનર થોડી વારમાં ઉમેરાશે.',
    'hi_IN': 'भुगतान मिल गया - आपका माइनर जल्द जोड़ा जाएगा.',
  },
  'upgradePriceOptions': {
    'en_US': 'Next level: @cost points or ₹@price',
    'gu_IN': 'આગલું લેવલ: @cost પોઇન્ટ અથવા ₹@price',
    'hi_IN': 'अगला लेवल: @cost पॉइंट या ₹@price',
  },
  "Rented miners run at their listed hashrate for the plan period and can't be upgraded.": {
    'en_US': "Rented miners run at their listed hashrate for the plan period and can't be upgraded.",
    'gu_IN': 'ભાડે લીધેલા માઇનર પ્લાનના સમય સુધી નક્કી હેશરેટ પર ચાલે છે અને અપગ્રેડ થઈ શકતા નથી.',
    'hi_IN': 'किराए के माइनर प्लान की अवधि तक तय हैशरेट पर चलते हैं और अपग्रेड नहीं हो सकते.',
  },
};
