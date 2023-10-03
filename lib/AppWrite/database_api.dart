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

  Future<DocumentList> getNoteEntries() {
    return databases.listDocuments(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_NOTEENTRY,
    );
  }

  Future<Document> addNoteEntry() { //required attributes inside the ().
    return databases.createDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_NOTEENTRY,
      documentId: ID.unique(),
      data: {
        //Add attributes here.
      },
    );
  }

  Future<Document> getNoteEntry({required String id}) {
    return databases.getDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_NOTEENTRY,
      documentId: id,
    );
  }

  Future<Document> updateNoteEntry({required String id}) {
    return databases.updateDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_NOTEENTRY,
      documentId: id,
    );
  }

  Future<dynamic> deleteNoteEntry({required String id}) {
    return databases.deleteDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_NOTEENTRY,
      documentId: id,
    );
  }
}
