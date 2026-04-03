const Map<String, String> loTranslations = {
  // App
  'app_name'             : 'Flexy',
  'retry'                : 'ລອງໃໝ່',
  'cancel'               : 'ຍົກເລີກ',
  'clear'                : 'ລ້າງ',
  'save'                 : 'ບັນທຶກ',
  'confirm'              : 'ຢືນຢັນ',
  'error'                : 'ຜິດພາດ',

  // Auth
  'sign_in'              : 'ເຂົ້າສູ່ລະບົບ',
  'sign_up'              : 'ສະໝັກສະມາຊິກ',
  'sign_out'             : 'ອອກຈາກລະບົບ',
  'sign_out_confirm'     : 'ອອກຈາກລະບົບ',
  'sign_out_question'    : 'ທ່ານຕ້ອງການອອກຈາກລະບົບບໍ?',
  'email'                : 'ອີເມວ',
  'password'             : 'ລະຫັດຜ່ານ',
  'first_name'           : 'ຊື່',
  'last_name'            : 'ນາມສະກຸນ',
  'create_account'       : 'ສ້າງບັນຊີ',
  'already_have_account' : 'ມີບັນຊີແລ້ວ? ',
  'no_account'           : 'ຍັງບໍ່ມີບັນຊີ? ',
  'welcome_back'         : 'ຍິນດີຕ້ອນຮັບຄືນ',
  'sign_in_subtitle'     : 'ເຂົ້າສູ່ລະບົບ Flexy',
  'create_subtitle'      : 'ສ້າງບັນຊີ Flexy ແລ້ວເລີ່ມຊື້ສິນຄ້າ',
  'fill_all_fields'      : 'ກະລຸນາຕື່ມຂໍ້ມູນໃຫ້ຄົບ',
  'password_too_short'   : 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ',
  'enter_email_password' : 'ກະລຸນາໃສ່ອີເມວ ແລະ ລະຫັດຜ່ານ',

  // Home
  'hello'                : 'ສະບາຍດີ,',
  'search_hint'          : 'ຄົ້ນຫາສິນຄ້າ...',
  'categories'           : 'ໝວດໝູ່',
  'products'             : 'ສິນຄ້າ',
  'no_products'          : 'ບໍ່ພົບສິນຄ້າ',

  // Search
  'search_page_hint'     : 'ຄົ້ນຫາສິນຄ້າ, ໝວດໝູ່...',
  'search_for_products'  : 'ຄົ້ນຫາສິນຄ້າ',
  'search_tip'           : 'ລອງ "ໝວກ", "ເກີບ", ຫຼື "ກິລາ"',
  'no_results_for'       : 'ບໍ່ພົບຜົນສຳລັບ',
  'try_different'        : 'ລອງຄຳຄົ້ນຫາອື່ນ',
  'results_for'          : 'ຜົນຄົ້ນຫາສຳລັບ',

  // Cart
  'cart'                 : 'ກະຕ່າສິນຄ້າ',
  'empty_cart'           : 'ກະຕ່າຂອງທ່ານຫວ່າງເປົ່າ',
  'empty_cart_sub'       : 'ເພີ່ມສິນຄ້າເພື່ອເລີ່ມຕົ້ນ',
  'subtotal'             : 'ລາຄາລວມ',
  'shipping'             : 'ຄ່າສົ່ງ',
  'free_shipping'        : 'ຟຣີ',
  'total'                : 'ລວມທັງໝົດ',
  'checkout'             : 'ຊຳລະເງິນ',
  'clear_cart'           : 'ລ້າງກະຕ່າ',
  'clear_cart_msg'       : 'ທ່ານຕ້ອງການລຶບສິນຄ້າທັງໝົດບໍ?',
  'added_to_cart'        : 'ຖືກເພີ່ມໃສ່ກະຕ່າ',
  'removed_from_cart'    : 'ຖືກລຶບອອກຈາກກະຕ່າ',

  // Product
  'description'          : 'ລາຍລະອຽດ',
  'tags'                 : 'ປ້າຍກຳກັບ',
  'in_stock'             : 'ມີສິນຄ້າ',
  'out_of_stock'         : 'ສິນຄ້າໝົດ',
  'add_to_cart'          : 'ເພີ່ມໃສ່ກະຕ່າ',
  'reviews'              : 'ຄຳເຫັນ',

  // Profile
  'my_profile'           : 'ໂປຣໄຟລ໌ຂອງຂ້ອຍ',
  'personal_info'        : 'ຂໍ້ມູນສ່ວນຕົວ',
  'change_language'      : 'ປ່ຽນພາສາ',
  'language_subtitle'    : 'English / ພາສາລາວ',
  'saved_addresses'      : 'ທີ່ຢູ່ທີ່ບັນທຶກໄວ້',
  'saved_addresses_sub'  : 'ຈັດການທີ່ຢູ່ຈັດສົ່ງ',
  'notifications'        : 'ການແຈ້ງເຕືອນ',
  'notifications_sub'    : 'ຈັດການການແຈ້ງເຕືອນ',
  'privacy_security'     : 'ຄວາມເປັນສ່ວນຕົວ & ຄວາມປອດໄພ',
  'privacy_security_sub' : 'ລະຫັດຜ່ານ ແລະ ຄວາມປອດໄພ',
  'help_support'         : 'ຊ່ວຍເຫຼືອ & ສະໜັບສະໜູນ',
  'help_support_sub'     : 'ຄຳຖາມທົ່ວໄປ ແລະ ຕິດຕໍ່ພວກເຮົາ',
  'save_edit'            : 'ບັນທຶກການແກ້ໄຂ',

  // Language picker
  'select_language'      : 'ເລືອກພາສາ',
  'lang_en'              : 'English',
  'lang_lo'              : 'ພາສາລາວ',

  // Theme picker
  'app_theme'            : 'ຮູບແບບແອັບ',
  'app_theme_sub'        : 'ມືດ / ສະຫວ່າງ / ລະບົບ',
  'select_theme'         : 'ເລືອກຮູບແບບ',
  'theme_dark'           : 'ສີມືດ',
  'theme_light'          : 'ສີສະຫວ່າງ',
  'theme_system'         : 'ຕາມລະບົບ',

  // Profile edit
  'edit_profile'         : 'ແກ້ໄຂໂປຣໄຟລ໌',
  'upload_photo'         : 'ຮູບໂປຣໄຟລ໌',
  'camera'               : 'ກ້ອງຖ່າຍຮູບ',
  'gallery'              : 'ຄັງຮູບ',
  'choose_avatar'        : 'ເລືອກ Avatar',
};
