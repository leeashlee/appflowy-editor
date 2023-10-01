// ignore_for_file: always_declare_return_types

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:noel_notes/AppWrite/auth_api.dart';
import 'package:noel_notes/component/constants.dart';

class DatabaseAPI {
  Client client = Client();
  late final Account account;
  late final Databases databases;
  final AuthAPI auth = AuthAPI();

  DatabaseAPI() {
    init();
  }

  init() {
    client
        .setEndpoint(APPWRITE_URL)
        .setProject(APPWRITE_PROJECT_ID)
        .setSelfSigned();
    account = Account(client);
    databases = Databases(client);
  }

  Future<DocumentList> getNotes() {
    return databases.listDocuments(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_NOTES,
    );
  }

  Future<Document> addNotes({required String message}) {
    return databases.createDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_NOTES,
      documentId: ID.unique(),
      data: {
        'text': message,
        'date': DateTime.now().toString(),
        'user_id': auth.userid,
      },
    );
  }

  Future<dynamic> deleteNotes({required String id}) {
    return databases.deleteDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_NOTES,
      documentId: id,
    );
  }
}
