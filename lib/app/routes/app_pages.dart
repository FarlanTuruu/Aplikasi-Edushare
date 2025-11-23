// File: app_pages.dart
import 'package:appedushare/app/modules/homepage/views/homepage_view.dart';
import 'package:get/get.dart';

import '../modules/auth/forgot_password/bindings/forgetpassword_binding.dart';
import '../modules/auth/forgot_password/views/forgetpassowrd_view.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';
import '../modules/chat/messages/bindings/messages_binding.dart';
import '../modules/chat/messages/views/messages_view.dart';
import '../modules/chat/rooms/bindings/rooms_binding.dart';
import '../modules/chat/rooms/views/rooms_view.dart';
import '../modules/collaboration/create/bindings/create_collaboration_binding.dart';
import '../modules/collaboration/create/views/create_collaboration_view.dart';
import '../modules/collaboration/detail/bindings/detail_collaboration_binding.dart';
import '../modules/collaboration/detail/views/detail_collaboration_view.dart';
import '../modules/collaboration/list/bindings/list_collaboration_binding.dart';
import '../modules/collaboration/list/views/list_collaboration_view.dart';
import '../modules/homepage/bindings/homepage_binding.dart';
import '../modules/homepage/views/detailmateri_view.dart';
import '../modules/notes/archived/bindings/archive_notes_binding.dart';
import '../modules/notes/archived/views/archive_notes_view.dart';
import '../modules/notes/create/bindings/create_notes_binding.dart';
import '../modules/notes/create/views/create_notes_view.dart';
import '../modules/notes/draft/bindings/draft_notes_binding.dart';
import '../modules/notes/draft/views/draft_notes_view.dart';
import '../modules/notes/list/bindings/list_notes_binding.dart';
import '../modules/notes/list/views/list_notes_view.dart';
import '../modules/notes/scheduled/bindings/scheduled_notes_binding.dart';
import '../modules/notes/scheduled/views/scheduled_notes_view.dart';
import '../modules/settings/profile/bindings/profile_settings_binding.dart';
import '../modules/settings/profile/views/profile_settings_view.dart';
import '../modules/settings/save_note/bindings/save_notes_binding.dart';
import '../modules/settings/save_note/views/save_notes_view.dart';
import '../modules/speech/create/bindings/create_speech_binding.dart';
import '../modules/speech/create/views/create_speech_view.dart';
import '../modules/speech/detail/bindings/detail_speech_binding.dart';
import '../modules/speech/detail/views/detail_speech_view.dart';
import '../modules/speech/list/bindings/list_speech_binding.dart';
import '../modules/speech/list/views/list_speech_view.dart';
import '../modules/speech/trash/bindings/trash_speech_binding.dart';
import '../modules/speech/trash/views/trash_speech_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    // -----------------------
    // AUTH
    // -----------------------
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgetPasswordView(),
      binding: Forgetbinding(),
    ),

    // -----------------------
    // SPEECH
    // -----------------------
    GetPage(
      name: _Paths.SPEECH_LIST,
      page: () => const ListSpeechView(),
      binding: ListSpeechBinding(),
    ),
    GetPage(
      name: _Paths.SPEECH_CREATE,
      page: () => const CreateSpeechView(),
      binding: CreateSpeechBinding(),
    ),
    GetPage(
      name: _Paths.SPEECH_DETAIL,
      page: () => const DetailSpeechView(),
      binding: DetailSpeechBinding(),
    ),
    GetPage(
      name: _Paths.SPEECH_TRASH,
      page: () => const TrashSpeechView(),
      binding: TrashSpeechBinding(),
    ),

    // -----------------------
    // NOTES
    // -----------------------
    GetPage(
      name: _Paths.NOTE_LIST,
      page: () => const ListNotesView(),
      binding: ListNotesBinding(),
    ),
    GetPage(
      name: _Paths.NOTE_CREATE,
      page: () => const CreateNotesView(),
      binding: CreateNotesBinding(),
    ),
    GetPage(
      name: _Paths.NOTE_ARCHIVED,
      page: () => const ArchiveNotesView(),
      binding: ArchiveNotesBinding(),
    ),
    GetPage(
      name: _Paths.NOTE_DRAFT,
      page: () => const DraftNotesView(),
      binding: DraftNotesBinding(),
    ),
    GetPage(
      name: _Paths.NOTE_SCHEDULED,
      page: () => const ScheduledNotesView(),
      binding: ScheduledNotesBinding(),
    ),

    // -----------------------
    // COLLABORATION
    // -----------------------
    GetPage(
      name: _Paths.COLLAB_LIST,
      page: () => const ListCollaborationView(),
      binding: ListCollaborationBinding(),
    ),
    GetPage(
      name: _Paths.COLLAB_CREATE,
      page: () => const CreateCollaborationView(),
      binding: CreateCollaborationBinding(),
    ),
    GetPage(
      name: _Paths.COLLAB_DETAIL,
      page: () => const DetailCollaborationView(),
      binding: DetailCollaborationBinding(),
    ),

    // -----------------------
    // CHAT
    // -----------------------
    GetPage(
      name: _Paths.CHAT_ROOMS,
      page: () => const RoomsView(),
      binding: RoomsBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_MESSAGES,
      page: () => const MessagesView(),
      binding: MessagesBinding(),
    ),

    // -----------------------
    // SETTINGS
    // -----------------------
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileSettingsView(),
      binding: ProfileSettingsBinding(),
    ),
    GetPage(
      name: _Paths.SAVE_NOTE,
      page: () => const SaveNotesView(),
      binding: SaveNotesBinding(),
    ),

    // -----------------------
    // HOMEPAGE
    // -----------------------
    GetPage(
      name: _Paths.HOMEPAGE,
      page: () => const HomepageView(),
      binding: HomepageBinding(),
    ),
    GetPage(
      name: _Paths.HOMEPAGE_DETAIL,
      page: () => DetailMateriView(data: Get.arguments),
      binding: HomepageBinding(),
    ),
  ];
}
