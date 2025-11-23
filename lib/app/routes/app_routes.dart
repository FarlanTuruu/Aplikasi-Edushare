part of 'app_pages.dart';

// ROUTE DEFINITIONS
abstract class Routes {
  Routes._();

  // AUTH
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;

  // HOMEPAGE
  static const HOMEPAGE = _Paths.HOMEPAGE;
  static const HOMEPAGE_DETAIL = _Paths.HOMEPAGE_DETAIL;

  // SPEECH
  static const SPEECH_LIST = _Paths.SPEECH_LIST;
  static const SPEECH_CREATE = _Paths.SPEECH_CREATE;
  static const SPEECH_DETAIL = _Paths.SPEECH_DETAIL;
  static const SPEECH_TRASH = _Paths.SPEECH_TRASH;

  // NOTES
  static const NOTE_LIST = _Paths.NOTE_LIST;
  static const NOTE_CREATE = _Paths.NOTE_CREATE;
  static const NOTE_ARCHIVED = _Paths.NOTE_ARCHIVED;
  static const NOTE_DRAFT = _Paths.NOTE_DRAFT;
  static const NOTE_SCHEDULED = _Paths.NOTE_SCHEDULED;

  // COLLAB
  static const COLLAB_LIST = _Paths.COLLAB_LIST;
  static const COLLAB_CREATE = _Paths.COLLAB_CREATE;
  static const COLLAB_DETAIL = _Paths.COLLAB_DETAIL;

  // CHAT
  static const CHAT_ROOMS = _Paths.CHAT_ROOMS;
  static const CHAT_MESSAGES = _Paths.CHAT_MESSAGES;

  // SETTINGS
  static const PROFILE = _Paths.PROFILE;
  static const SAVE_NOTE = _Paths.SAVE_NOTE;
}

abstract class _Paths {
  _Paths._();

  // AUTH
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';

  // HOMEPAGE
  static const HOMEPAGE = '/homepage';
  static const HOMEPAGE_DETAIL = '/detail-materi';

  // SPEECH
  static const SPEECH_LIST = '/speech/list';
  static const SPEECH_CREATE = '/speech/create';
  static const SPEECH_DETAIL = '/speech/detail';
  static const SPEECH_TRASH = '/speech/trash';

  // NOTES
  static const NOTE_LIST = '/notes/list';
  static const NOTE_CREATE = '/notes/create';
  static const NOTE_ARCHIVED = '/notes/archived';
  static const NOTE_DRAFT = '/notes/draft';
  static const NOTE_SCHEDULED = '/notes/scheduled';

  // COLLABORATION
  static const COLLAB_LIST = '/collab/list';
  static const COLLAB_CREATE = '/collab/create';
  static const COLLAB_DETAIL = '/collab/detail';

  // CHAT
  static const CHAT_ROOMS = '/chat/rooms';
  static const CHAT_MESSAGES = '/chat/messages';

  // SETTINGS
  static const PROFILE = '/settings/profile';
  static const SAVE_NOTE = '/settings/save-note';
}
