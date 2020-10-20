db.adminCommand('listDatabases');
db = db.getSiblingDB('wh-journal-docker');
db.getCollectionNames();
cursor = db.collection.find();
while ( cursor.hasNext() ) {
   printjson( cursor.next() );
}
