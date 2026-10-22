# Mongo Cheatsheet

## Inserarea

```mongodb
db.collection.insert(
    <document or array of documents>,
    {
      writeConcern: <document>,
      ordered: <boolean>
    }
)
```

Pentru a insera documentul în colecția students:

```mongodb
db.students.insert(
{
    "student":
        {
            "firstname": "Ion",
            "lastname": "Popescu"
        },
    "an": 4,
    "grupa": "342C3",
    "materii":
        [
            {"nume": "Comp", "an": 4},
            {"nume": "BD2" , "an": 4},
            {"nume": "SO2" , "an": 4}
        ],
    "cunostinte": ["SQL", "Java", "PL/SQL"]
}
)
```

Pentru a vă ușura munca puteți să vă creați variabile la nivelul consolei. Dacă se dorește inserarea mai multor înregistrări, se poate declara un vector.

```mongodb
var stud = {"student": { "firstname": "Andrei", "lastname": "Ionescu"}, "an": 4, "grupa": "341C4", "materii": [{"nume": "BD2", "an": 4}, {"nume": "IA", "an": 4},{"nume": "IAUT", "an": 4}], "cunostinte": ["C", "C++", "SQL"] }

db.students.insert(stud)

var studs = [
    {"student": { "firstname": "George", "lastname": "Popescu"}, "an": 4, "grupa": "341C2", "materii": [{"nume": "BD2", "an": 4}, {"nume": "IOCLA", "an": 2}], "cunostinte": ["Python", "SQL"]  },
    {"student": { "firstname": "Georgiana", "lastname": "Petrescu"}, "an": 4, "grupa": "341C2", "materii": [{"nume": "BD2", "an": 4}, {"nume": "SCAD", "an": 4}], "cunostinte": ["Python", "SQL"]  },
    {"student": { "firstname": "Valentina", "lastname": "Vasilescu"}, "an": 3, "grupa": "331CA", "materii": [{"nume": "BD", "an": 3}, {"nume": "RL", "an": 3}, {"nume": "APD", "an": 2}], "cunostinte": ["Java", "C++", "SQL"] },
    {"student": { "firstname": "Grigore", "lastname": "Ionescu"}, "an": 4, "grupa": "342C2", "materii": [{"nume": "BD2", "an": 4}, {"nume": "VLSI", "an": 4}, {"nume": "SRIC", "an": 4}, {"nume": "SO", "an": 3}], "cunostinte": ["C", "Python", "SQL", "Ruby"] },
    {"student": { "firstname": "Andrei", "lastname": "Popescu"}, "an": 3, "grupa": "332CA", "materii": [{"nume": "CN1", "an": 2}, {"nume": "CN2", "an": 2}, {"nume": "RL", "an": 3}], "cunostinte": ["C", "Python", "SQL", "Ruby"] },
    {"student": { "firstname": "Ana", "lastname": "Georgescu"}, "an": 4, "grupa": "342C5", "materii": [{"nume": "BD2", "an": 4}, {"nume": "UBD", "an": 4}, {"nume": "SRIC", "an": 4}, {"nume": "SO", "an": 3}], "cunostinte": ["C", "Python", "SQL", "Ruby"], "sef": true },
]

db.students.insert(studs)
```

## Selectarea datelor

### Select

În MongoDB operația de selecție a datelor este `find()`. Sintaxa comenzii este:

```mongodb
db.collection.find(query, projection)
```

Unde:

- `query` reprezintă lista de filtre
- `projection` reprezintă câmpurile care vor fi afișate

Dacă parametrul `query` lipsește, atunci se selectează toate documentele. Dacă parametrul `projection` lipsește atunci se afișează toate câmpurile documentului. Comanda `find()` face paginație, arătând în consolă 10 înregistrări.

Să se selecteze toți studenții din colecția students, baza de date faculty:

```mongodb
db.students.find()
```

Dacă se dorește întoarcerea unei singur document se folosește `findOne()`:

```mongodb
db.students.findOne()
```

Dacă se dorește întoarcerea unui număr `n` de documente se folosește `limit(n)`:

```mongodb
db.students.find().limit(3)
```

Dacă se dorește sortarea rezultatelor după valoare unui anumit câmp se folosește `sort({label_1: order, label_2: order,…, label_n:order})` unde `order` este `1` pentru ascendent și `-1` pentru descendent.

```mongodb
db.students.find().sort({"grupa": 1})
```

Dacă se dorește afișarea într-un mod citibil în consolă se folosește `pretty()`:

```mongodb
db.students.find().pretty()
```

`pretty`, `limit` și `sort` se pot folosi împreună:

```mongodb
db.students.find().sort({"student.firstname": 1}).limit(3).pretty()
```

##### Să se selecteze primele 4 rezultate ale unei cereri care întoarce toți studenți ordonați descrescător după nume:

```mongodb
db.students.find().sort({"student.firstname": -1}).limit(4);
```

### Filtrarea cererilor

Pentru a filtra rezultatele se folosește parametru `query`.

Pentru comparație avem:

- `:` - egalitate
- `$ne` - diferit de (not equal)
- `$gt` - mai mare
- `$gte` - mai mare sau egal
- `$lt` - mai mic
- `$lte` - mai mic sau egal
- `$in` - căutare într-o listă
- `$all` - căutare cu egalitate pe toate elementele dintr-o listă

```mongodb
db.students.find({"student.firstname": "Ion"})
db.students.find({an: {$gte: 4}})
db.students.find({"materii.nume": {$in: ['SCAD', 'IA']} })
db.students.find({"grupa": /^341/ })
db.students.find({"cunostinte": {$all: [/^J/, /^C/ ]}})
```

Operatori logici:

- `$or` - sau logic
- `$and` - și logic
- `$not` - negare logic

```mongodb
db.students.find({$or:  [{"student.lastname": "Ionescu"}, {"cunostinte": /^C/}]})
db.students.find({$and: [{"student.lastname": "Ionescu"}, {"cunostinte": /^C/}]})
```

Operatori utili pentru vectori:

- `$size` pentru a verifica dimensiune
- `0, 1, 2,…` pentru poziționare (indexare vectorilor începe de la 0)

```mongodb
db.students.find({"cunostinte": {$size: 2}})
db.students.find({"cunostinte.2": "SQL"})
db.students.find({"materii.0.nume": "BD2"})
```

Pentru a verifica existența unui câmp se folosește `$exists`:

```mongodb
db.students.find({"sef": true})
db.students.find({"sef": {$exists: true}})
db.students.find({"sef": false})
db.students.find({"sef": {$exists: false}})
```

##### Să se selecteze toți studenții din anul 4 care au restanțe (au materii din ani mai mici) și știu limbajele de programare C și SQL:

```mongodb
db.students.find({an: 4, "materii.an": {$lt: 4}, "cunostinte": {$all: ["C", "SQL"]}})
```

### Proiecția

Pentru a proiecta doar anumite câmpuri se folosește parametrul `projection`. În cazul în care nu se folosește filtrare se pun acolade goale pentru `query`.

```mongodb
db.students.find({}, {"student.firstname": 1})
```

O cerere cu `projection` va întoarce doar câmpurile specificate și `_id`. Dacă se dorește să se elimine câmpul `_id` atunci proiecția trebuie să conțină și `"_id": 0`:

```mongodb
db.students.find({}, {"_id": 0, "student.firstname": 1})
```

##### Să se selecteze studenții care nu sunt șefi și au cunoștințe de “Python” pe a doua poziție din vectorul de cunoștințe. Afișați doar numele, prenumele și vectorul de cunoștințe.

```mongodb
db.students.find(
  {
    "sef": { $exists: false },
    "cunostinte.1": "Python",
  },
  { "_id": 0, "student.firstname": 1, "student.lastname": 1, "cunostinte": 1 }
);
```

## Modificarea datelor

Pentru a modifica datele se poate folosi una din comenzile:

```mongodb
db.collection.update(<query>, <update>, <options>)​
```

Unde:

- `query` - filtrează datele
- `update` - setează date care trebuie modificate
- `options` - diferite opțiuni, e.g.:
- `upsert`: <boolean> - crează un nou document în cazul în care nu se găsește nici un document cu filtrul
- `multi`: <boolean> - modifică mai multe documente

Pentru a seta o valoare se folosește `$set`:

```mongodb
db.students.update({"student.firstname": "George"}, {$set: {"grupa": "342C1"}})
db.students.update({an: 4, "student.firstname": "Grigore"}, {$set: {cunostinte: ["C++"]}})
```

Folosind `$set` se suprascrie valoarea pentru câmp. În cazul în care dorim sa modificăm o structură de tip vector folosiți `$push`. Dacă se dorește să se adauge mai multe valori, se poate folosi $push împreună cu `$each`.

```mongodb
db.students.update({an: 4, "student.firstname": "Grigore"}, {$push: {"cunostinte": "C"}})
db.students.update({an: 4, "student.firstname": "Grigore"}, {$push: {"cunostinte":{$each: ["Python", "SQL", "Ruby"]}}})
```

Dacă se dorește să se modifice valoare unui element dintr-o listă sau a unui câmp dintr-un document imbricat care se găsește în listă se poate folosi $. Trebuie să selectați și valoare/câmpul care se dorește să fie modificat în query:

```mongodb
db.students.update({"student.firstname": "Grigore", "cunostinte": "C"}, {$set: {"cunostinte.$": "Java"}})
db.students.update({"student.firstname": "Grigore", "materii.nume": "SRIC"}, {$set: {"materii.$.nume": "SPG"}})
db.students.update({"student.firstname": "Grigore", "materii.nume": "SPG"}, {$set: {"materii.$.nume": "SRIC", "materii.$.an":4}})
```

##### Să se adauge la toți studenți de anul 3 materiile EGC și LFA (nume si an) folosind o singură comandă.

```mongodb
db.students.update({an: 3}, {$push: {materii: {$each: [{nume: "EGC", an: 3}, {nume: "LFA", an: 3}] } }}, {multi: true})
```

Alte funcții care modifică datele sunt:

```mongodb
db.collection.updateOne(<query>, <update>, <options>)​

db.collection.updateMany(<query>, <update>, <options>)​
```

## Ștergerea datelor

Pentru a șterge un document dintr-o colecție se folosește comanda:

```mongodb
db.collection.remove(<query>, <justOne>)
```

Unde:

- `query` - filtrează datele
- `justOne` - boolean pentru a șterge unul (true) sau mai multe (false - implicit) documente

```mongodb
 db.students.remove({"an": {$lt: 4}})
```

Pentru a șterge toate documentele dintr-o colecție se folosește:

```mongodb
db.collection.remove({})
```

```mongodb
db.students.remove({})
```

Alte comenzi care pot fi utilizare pentru a șterge documente dintr-o colecție sunt:

```mongodb
db.collection.deleteOne(<filter>)​

db.collection.deleteMany(<filter>)​
```

##### Să se șteargă doar un student care are materia BD2.

```mongodb
db.students.deleteOne({"materii.nume": "BD2"})
```

## Indexare

MongoDB suport diferite tipuri de indecși. Indecși sunt utilizați pentru a crește performanțele operațiilor de căutare. Indecși sunt creați la nivel de colecție. Pentru a crea un index se folosește comanda createIndex(). La creare se specifică numele câmpului (i.e., label) și modul de ordonare a indexului (i.e., order)

Indecși simpli:

```mongodb
db.collection.createIndex({“label”: order})
```

Indecși compusi:

```mongodb
db.collection.createIndex({“label_1”: order_1, “label_2”: order_2, …})
```

Indecși pe documente imbricate:

```mongodb
db.collection.createIndex({“label_1.nested_label”: order_1, “label_2.nested_label”: order_2, …})
```

Indecși geo-spațiali:

```mongodb
db.collection.createIndex({“label_1.nested_label”: “2d”})
```

Indecși textuali (o colecție poate să aibă un singur index textual, dar acesta poate fi compus):

```mongodb
db.collection.createIndex({“label_1”: “text”, “label_2”: “text”, …})
```

Indecși hashed (utili pentru sharding):

```mongodb
db.collection.createIndex({“label”: “hashed”})
```

```mongodb
db.documents.createIndex({author: 1})
db.documents.createIndex({gender: 1, age: 1})
db.documents.createIndex({"words.word": 1})
db.documents.createIndex({"geoLocation": "2d"})
db.documents.createIndex({"lemmaText": "text"})
db.documents.createIndex({"date": "hashed"})
```

Pentru a vedea toți indecșii se folosește comanda

```mongodb
db.collection.getIndexes()
```

Pentru a șterge un index se folosește comanda

```mongodb
db.collection.dropIndexes(“index_name”)
```

Pentru a șterge toți indecșii (cu excepția indexului de pe cheia primară) se folosește comanda

```mongodb
db.collection.dropIndexes()
```

### Utilizare indecși geo-spațiali

- Pentru a găsi documentele de lângă un punct `p=[x, y]` se folosește `$near`
- Pentru a găsi documentele care se găsesc în diferite figuri geometrice se folosește `$within`:
  - Pentru un cerc cu centrul într-un punct `p=[x, y]` și o rază `r` se folosește $center
  - Pentru un dreptunghi definit prin punctele din stânga jos și dreapta sus se folosește `$box`
  - Pentru un poligon dat de o listă puncte se folosește `$polygon`

```mongodb
db.documents.find( { geoLocation: { $near: [25, 25] } }, {geoLocation: 1} )
db.documents.find( { geoLocation: { $within: { $center: [[25, 10], 3] } } }, {geoLocation: 1} )
db.documents.find( { geoLocation: { $within: { $box: [[25, 40], [30, 45]] } } }, { geoLocation: 1 } )
db.documents.find( { geoLocation: { $within: { $polygon: [[20, 40], [40, 50], [30, 30]] } } },  { geoLocation: 1 } )
```

### Utilizare indecși textuali

Pentru a utiliza un index textual se folosește următoare sintaxă:

```mongodb
{
  $text:
    {
      $search: <string>,
      $language: <string>,
      $caseSensitive: <boolean>,
      $diacriticSensitive: <boolean>
    }
}
```

Unde:

- `$search` - este șirul de cuvinte căutat sau fraza căutată
- `$language` - este limba pentru cuvintele căutate
- `$caseSensitive` - dacă se caută case sensitive sau nu
- `$diacriticSensitive` - dacă se ține cont de diacritice sau nu

```mongodb
# Caută un cuvânt
db.documents.find( { $text: { $search: "coffee", $language: "english", $caseSensitive: false, $diacriticSensitive: false } } ,  { lemmaText: 1 } )

# Caută mai multe cuvinte (se folosește operatorul or)
db.documents.find( { $text: { $search: "coffee cup", $language: "english", $caseSensitive: false, $diacriticSensitive: false } } ,  { lemmaText: 1 } )

# Caută o frază
db.documents.find( { $text: { $search: "\"heaven tonight\"", $language: "english", $caseSensitive: false, $diacriticSensitive: false } } ,  { lemmaText: 1 } )

# Caută o frază cu un scor de relevanță
db.documents.find( { $text: { $search: "\"heaven tonight\"", $language: "english", $caseSensitive: false, $diacriticSensitive: false } } ,  { score: { $meta: "textScore" }, lemmaText: 1, _id: 0})
```

##### Să se găsească toate documentele care se află într-un dreptunghi dat de punctele [20, -100] și [40, 90], care să conțină cuvintele tech și engineering. Cererea să se folosească de indexul textual. Afișeți câmpul rawText. Să se refacă cererea utilizând alt câmp din document.

```mongodb
db.documents.find(
  {
    $text: {
      $search: "tech engineering",
      $language: "english",
      $caseSensitive: false,
      $diacriticSensitive: false,
    },
    geoLocation: {
      $within: {
        $box: [
          [20, -100],
          [40, 90],
        ],
      },
    },
  },
  { rawText: 1 }
);
```

## Funcții

Să se scrie o funcție care primește un query pentru filtrare și împarte lemmaText în cuvinte. Funcția va întoarce un vector.

```mongodb
tokenization = function (q) {
  var cursor = db.documents.find(q, { _id: 0, lemmaText: 1 });
  var tokens = Array();
  cursor.forEach(function (elem) {
    tokens = tokens.concat(elem["lemmaText"].split(" "));
  });
  return tokens;
};

// utilizate
var q = { gender: "male" };
tokens = tokenization(q);
```

##### Să se scrie o funcție numită countWords care primește un query pentru filtrare și numără aparițiile unui cuvânt. Funcția va întoarce un obiect de forma {word_1: count, word_2: count, …}. Folosiți funcția tokenization.

```mongodb
countWords = function (q) {
  var tokens = tokenization(q);
  var count = {};
  tokens.forEach(function (word) {
    if (count[word]) {
      count[word] += 1;
    } else {
      count[word] = 1;
    }
  });
  return count;
};

var q1 = {
  gender: "female"
};

countWords(q1);
```

### Funcții stocate

Funcțiile pot fi stocate la nivelul MongoDB. Pentru acest lucru se folosește o colecție specială numită system.js. Stocarea se face cu comanda:

```mongodb
db.system.js.save(_id: “function_name”, value: “function_body”)
```

Pentru a lucra cu funcțiile stocare (a le încărca în sesiune) se folosește comanda:

```mongodb
db.loadServerScripts()
```

```mongodb
db.system.js.save(
   {
     _id: "tokenization",
     value : function(q){
                var cursor = db.documents.find(q,{"_id": 0, lemmaText: 1});
                var tokens = Array();
                cursor.forEach(function(elem){
                    tokens = tokens.concat(elem["lemmaText"].split(" "));
                });
                return tokens;
            }
   }
)

db.loadServerScripts()
```

##### Salvați și apoi încărcați în sesiune funcția countWords.

```mongodb
db.system.js.save(
   {
     _id: "countWords",
     value : function(q){
                var tokens = tokenization(q);
                var count = {};
                tokens.forEach(function(word){
                    if(count[word]){
                        count[word] += 1;
                    } else {
                        count[word] = 1;
                    }
                });
                return count;
            }
   }
)

db.loadServerScripts()
```

## Agregarea datelor

### Funcții de agregare

- Count

```mongodb
db.collection.count(query)

// Cate documente au lungimea textului lematizat 10
db.documents.count({lemmaTextLength: 10})
```

- Distinct

```mongodb
db.collection.distinct(field, query)​

// afiseaza varstele distincte
db.documents.distinct("age")

// afiseaza varstele distincte pentru female
db.documents.distinct("age", {gender: "female"}).sort()
```

##### Afișați toate cuvintele distincte. Folosiți câmpul words.

```mongodb
db.documents.distinct("words.word")
```

### Aggregation Pipeline

```mongodb
db.collection.aggregate(
    { $match: <query> },
    { $unwind: <array> },
    { $project: <projection>},
    { $group: <aggregation_group, aggregation_functions> },
    { $sort: <sorting_fields> },
)
```

Unde:

- `$match` - filtrează documentele de intrare după un query
- `$unwind` - procesează elementele dintr-un vector
- `$project` - proiectează câmpurile documentului
- `$group` - grupează documentele și aplică funcții de agregare
- `$sort` - reordonează documentele de intrare după o cheie

Nota: Contează ordinea în care sunt folosiți operatorii.

##### Să se utilizeze Aggregation Pipeline pentru a calcula numărul de apariții ale cuvintelor.

```mongodb
db.documents.aggregate([
    { $match: q },
    { $project: { words: { $split: ["$lemmaText", " "]}}},
    { $unwind: "$words" },
    { $group: { _id: "$words", counts: { $sum: 1 } } }
])
```

##### Să se utilizeze Aggregation Pipeline pentru a calcula numărul de apariții ale cuvintelor folosind coloana words.

```mongodb
var q = {
  $or: [
    { lemmaText: { $regex: ".*" + "a" + ".*" } },
    { lemmaText: { $regex: ".*" + "e" + ".*" } },
    { lemmaText: { $regex: ".*" + "i" + ".*" } },
    { lemmaText: { $regex: ".*" + "o" + ".*" } },
    { lemmaText: { $regex: ".*" + "u" + ".*" } }
  ]
};

db.documents.aggregate([
    { $match: q },
    { $unwind: "$words" },
    { $group: { _id: "$words.word", counts: { $sum: 1 } } }
])
```

### MapReduce

```mongodb
db.collection.mapReduce(
    mapFunction,
    reduceFunction,
    {
        finalize: <function>,
        out: <output>,
        query: <document>,
        sort: <document>,
        limit: <number>,
        scope: <document>
    }
)
```

Unde:

- `mapFunction` - funcția map
- `reduceFunction` - funcția reduce
- `finalize` - (opțional) funcție pentru finalizare, se aplică după ce se termină procesul și datele sunt agregate
- `out` - (opțional) colecția unde va fi salvat rezultatul
- `query` - (opțional) filtru pentru documentele de intrare
- `sort` - (opțional) ordonează documentele de intrare după cheie
- `limit` - (opțional) limitează numărul de documente de intrare
- `scope` - (opțional) variabile din exterior care pot fi folosite în funcțiile map, reduce și finalize

Comanda mapReduce este o mapare peste comanda mapReduce din MongoDB

```mongodb
db.runCommand(
    {
        mapReduce: <collection>,
        map: <function>,
        reduce: <function>,
        finalize: <function>,
        out: <output>,
        query: <document>,
        sort: <document>,
        limit: <number>,
        scope: <document>
    }
)
```

##### Să se utilizeze MapReduce pentru a calcula numărul de apariții ale cuvintelor.

```mongodb
mapFunction = function() {
    var tokens = this.lemmaText.split(" ");
    for (var idx=0; idx<tokens.length; idx++){
        emit(tokens[idx], 1);
    }
}

reduceFunction = function(key, values) {
    return Array.sum(values);
};

var q = {"gender": "female"}
db.documents.mapReduce(mapFunction, reduceFunction, {query: q, out: "wordCounts"});

db.wordCounts.count()

db.wordCounts.find({"_id": "0"})

db.wordCounts.drop()
```

##### Să se utilizeze MapReduce pentru a calcula numărul de apariții ale cuvintelor folosind câmpul words.

```mongodb
mapFunction = function() {
    for (var idx=0; idx<this.words.length; idx++){
        emit(this.words[idx].word, 1);
    }
}

reduceFunction = function(key, values) {
    return Array.sum(values);
};

var q = {
  $or: [
    { lemmaText: { $regex: ".*" + "a" + ".*" } },
    { lemmaText: { $regex: ".*" + "e" + ".*" } },
    { lemmaText: { $regex: ".*" + "i" + ".*" } },
    { lemmaText: { $regex: ".*" + "o" + ".*" } },
    { lemmaText: { $regex: ".*" + "u" + ".*" } }
  ]
};

db.documents.mapReduce(mapFunction, reduceFunction, {query: q, out: "wordCounts"});

db.wordCounts.count()

db.wordCounts.find({"_id": "0"})

db.wordCounts.drop()
```

## Exerciții

### Să se găsească documentele care conțin cel mai popular hashtag.

```mongodb
const mostPopularHashtag = db.documents.aggregate([
  { $unwind: "$hashtags" },
  { $group: { _id: "$hashtags", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
]).next();

printjson(mostPopularHashtag);

db.documents.find({ hashtags: mostPopularHashtag._id });
```

### Să se găsească cel mai activ autor după numărul de documente create.

```mongodb
const mostActiveAuthor = db.documents.aggregate([
  { $group: { _id: "$author", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
]).next();

printjson(mostActiveAuthor);

<!-- db.documents.find({ author: mostActiveAuthor._id }); -->
```

### Pentru toate documentele care content cel mai popular hashtag vedeti distributia de varsta.

```mongodb
const mostPopularHashtag = db.documents.aggregate([
  { $unwind: "$hashtags" },
  { $group: { _id: "$hashtags", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 1 }
]).next();

printjson(mostPopularHashtag);

const ageDistribution = db.documents.aggregate([
  { $match: { hashtags: mostPopularHashtag._id } },
  { $group: { _id: "$age", count: { $sum: 1 } } }
]).toArray();

printjson(ageDistribution);
```

### Cate documente cu autori Tineri (<= 35 de ani) avem pentru fiecare gen?

```mongodb
const youngAuthors = db.documents.aggregate([
  { $match: { age: { $lte: 35 } } },
  { $group: { _id: "$gender", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]).toArray();

printjson(youngAuthors);
```

### Pentru documentele care se afla in cercul de centru (20,20) si raza 100, care sunt top 3 cele mai folosite Tipuri de Enitati (campul namedEntities.type; la egalitate sortati alfabetic)?

```mongodb
const top3Entities = db.documents.aggregate([
  {
    $match: {
      geoLocation: {
        $geoWithin: {
          $center: [[20, 20], 100]
        }
      }
    }
  },
  { $unwind: "$namedEntities" },
  { $group: { _id: "$namedEntities.type", count: { $sum: 1 } } },
  { $sort: { count: -1, _id: 1 } },
  { $limit: 3 }
]).toArray();

printjson(top3Entities);
```

### Pentru toate documentele publicate in ultima luna disponibila in colectie care au minim 2 hashtag-uri gasiti cel mai folosit tip de entitate si pentru acel tip de entitate afisati top 3 valori ale acelei entitati. Exemplu de rezultat "tip Entitate = LOCATION; Top3: North, South, East".

```mongodb
var lastDate = db.documents
  .aggregate([
    {
      $project: {
        year: { $year: "$date" },
        month: { $month: "$date" },
        _id: 0,
      },
    },
    {
      $sort: {
        date: -1,
      },
    },
  ])
  .next();

var lastMonth = lastDate.month;
var lastYear = lastDate.year;

// cauta toate documentele din ultima luna si an care au minim 2 hashtaguri
var most_popular_ent_typr = db.documents
  .aggregate([
    {
      $match: {
        $expr: {
          $and: [
            { $eq: [{ $year: "$date" }, lastYear] },
            { $eq: [{ $month: "$date" }, lastMonth] },
            { $gte: [{ $size: "$hashtags" }, 2] },
          ],
        },
      },
    },
    {
      $project: {
        _id: 0,
        namedEntities: 1,
      },
    },
    {
      $unwind: "$namedEntities",
    },
    {
      $group: {
        _id: "$namedEntities",
        count: { $sum: 1 },
      },
    },
    {
      $sort: {
        count: -1,
      },
    },
  ])
  .next()._id.type;

var top_3_ent = db.documents
  .aggregate([
    {
      $project: {
        _id: 0,
        namedEntities: 1,
      },
    },
    {
      $unwind: "$namedEntities",
    },
    {
      $match: {
        "namedEntities.type": most_popular_ent_typr,
      },
    },
    {
      $group: {
        _id: "$namedEntities.entity",
        count: { $sum: 1 },
      },
    },
    {
      $sort: {
        count: -1,
      },
    },
    {
      $limit: 3,
    },
  ])
  .toArray();

print("tip Entitate = " + most_popular_ent_typr + " ");
print("\nTop3: ");
top_3_ent.forEach(function (ent) {
  print(ent._id);
});
```

### Pentru toate documentele cu text(rawText) mai lung decat media lungimii care au minim o entitate gasiti cate elemente (cuvinte) au fost eliminate (rawText -> cleanText) prin lematizare si pentru documentele care au minim 2 elemente eliminate afisati raportul raportul "namedEntities" VS "hashtags" si cea mai frecventa entitate din fiecare categorie. Exemplu de rezultat "40 namedEntities VS 20 hashtags; North VS #CarolinaWx"

```mongodb
use('BD2');

db.documents.find();

var lungime_medie = db.documents.aggregate([
    {
        $project: {
            _id: 0,
            rawText: 1,
            lungime: { $strLenCP: "$rawText" }
        }
    },
    {
        $group: {
            _id: null,
            avgLungime: { $avg: "$lungime" }
        }
    }
]).toArray()[0].avgLungime;

print(lungime_medie);

db.documents.aggregate([
    {
        $match: {
            $expr: {
                $and: [
                    {$gt: [{ $strLenCP: "$rawText" }, lungime_medie]},
                    {$gte: [{ $size: "$namedEntities" }, 1]}
                ]
            }
        }
    },
    {
        $project: {
            _id: 0,
            rawText: 1,
            cleanText: 1,
            cuvinte_raw: {$size :{ $split: ["$rawText", " "] }},
            cuvinte_clean: {$size :{ $filter: { input: { $split: ["$cleanText", " "] }, as: "cuvant", cond: { $ne: ["$$cuvant", ""] } } }},
            namedEntities: 1,
            hashtags: 1
        }
    },
    {
        $project: {
            dif : { $subtract: ["$cuvinte_raw", "$cuvinte_clean"] },
            namedEntities: 1,
            hashtags: 1
        }
    },
    {
        $match: {
            $expr: {
                $gte: ["$dif", 2]
            }
        }
    },
    {
        $project: {
            _id: 0,
            namedEntities: 1,
            hashtags: 1,
            no_namedEntities: {$size: "$namedEntities"},
            no_hashtags: {$size: "$hashtags"}
        }
    }
])

???????????
```

### Pentru toate documentele care contin minim 7 cuvinte distincte in "rawText" si minim un hashtag gasiti media varstei autorilor si pentru toti vedeti cel mai popular hashtag pentru cei sub media varstei vs cel pentru cei peste media varstei, cu strict. Exemplu de rezultat "Cel mai folosit # pentru cei sub 32 de ani este #CarolinaWx, iar pentru cei peste 32 de ani este #ClaytonNC_Wx".

```mongodb
use("BD2");

// Step 1: Calculate the average age of authors for documents with at least 7 distinct words in "rawText" and at least one hashtag
const avgAgeResult = db
  .getCollection("documents")
  .aggregate([
    {
      $match: {
        $expr: { $gte: [{ $size: { $setUnion: ["$words.word"] } }, 7] },
        hashtags: { $exists: true, $ne: [] },
      },
    },
    {
      $group: {
        _id: null,
        avgAge: { $avg: "$age" },
      },
    },
  ])
  .toArray();

const avgAge = avgAgeResult[0].avgAge;

// Step 2: Find the most popular hashtag for authors below and above the average age
const popularHashtags = db
  .getCollection("documents")
  .aggregate([
    {
      $match: {
        $expr: { $gte: [{ $size: { $setUnion: ["$words.word"] } }, 7] },
        hashtags: { $exists: true, $ne: [] },
      },
    },
    {
      $facet: {
        belowAvgAge: [
          { $match: { age: { $lt: avgAge } } },
          { $unwind: "$hashtags" },
          { $group: { _id: "$hashtags", count: { $sum: 1 } } },
          { $sort: { count: -1 } },
          { $limit: 1 },
        ],
        aboveAvgAge: [
          { $match: { age: { $gte: avgAge } } },
          { $unwind: "$hashtags" },
          { $group: { _id: "$hashtags", count: { $sum: 1 } } },
          { $sort: { count: -1 } },
          { $limit: 1 },
        ],
      },
    },
  ])
  .toArray();

const belowAvgHashtag = popularHashtags[0].belowAvgAge[0]._id;
const aboveAvgHashtag = popularHashtags[0].aboveAvgAge[0]._id;

print(
  `Cel mai folosit # pentru cei sub ${avgAge} de ani este ${belowAvgHashtag}, iar pentru cei peste ${avgAge} de ani este ${aboveAvgHashtag}.`
);

```

### Pentru toate documentele publicate in primul an disponibil in colectie (2p) care au autor sau "male" sau "female" (1p) afisati cati autori sunt in urmatoarele categorii de varsta: 21-; 22 - 35; 36 - 55; 56+ (3p). Pentru cea mai populara categorie de varsta afisati care este numarul mediu de cuvinte folosite vs numarul mediu de non-cuvinte, adica entitati si hashtags (4p). Exemplu de rezultat "21-: 10 persoane; 22 - 25: 3 persoane.... Pentru categoria 21- se folosesc, in general, 7 cuvinte si 2 non-cuvinte".

```mongodb
use("BD2");

db.documents.distinct("age", {gender: "female"}).sort()

const firstYear = db.documents.aggregate([
  {
    $group: {
      _id: null,
      minYear: { $min: { $year: "$date" } },
    },
  },
]).next().minYear;

printjson(firstYear);

const maleOrFemaleAuthors = db.documents.aggregate([
  {
    $match: {
      $expr: { $eq: [{ $year: "$date" }, firstYear] },
      $expr: { $or: [{ gender: "male", gender: "female"}]},
    }}]);

printjson(maleOrFemaleAuthors);

// without $bucket and $group switch

const ageCategories = db.documents.aggregate([
  {
    $match: {
      $expr: { $eq: [{ $year: "$date" }, firstYear] },
      $expr: { $or: [{ gender: "male", gender: "female"}]},
    }},
    {
      $project: {
        _id: 0,
        age: 1,
      }
    },
    {
      $bucket: {
        groupBy: "$age",
        boundaries: [0, 21, 36, 56],
        default: "56+",
        output: {
          "21-": { $sum: { $cond: [{ $lte: ["$$age", 21] }, 1, 0] } },
          "22-35": { $sum: { $cond: [{ $and: [{ $gt: ["$$age", 21] }, { $lte: ["$$age", 35] }] }, 1, 0] } },
          "36-55": { $sum: { $cond: [{ $and: [{ $gt: ["$$age", 35] }, { $lte: ["$$age", 55] }] }, 1, 0] } },
          "56+": { $sum: { $cond: [{ $gt: ["$$age", 55] }, 1, 0] } },
        }
      }
    }
]).toArray();

printjson(ageCategories);
```

NR 1

⁠ Pentru toate documentele unde se repeta minim un cuvant (1p) si contin minim 2 tipuri distincte de entitati (2p) vrem sa vedem:
daca sunt entitati care se repeta, DA/NU = (2p)

care este cea mai populara pereche de entitati = (2p)

daca cumva entitatile care se repeta au unul din tipul perechii populare (3p)

Exemplu de rezultat: “DA, cea mai populara pereche este ORGANIZATION/PERSON, da PERSON se repeta si este si populara”

NR 2

Pentru toate documentele care contin link-uri (1p) si sunt publicate de cel mai prezent gen de autor (3p) gasiti cea mai populara sursa pentru acele link-uri (2p) si vedeti in cate alte documente care nu fac parte din aceste interogare se gasesc (2p). Pentru acele documente faceti o statistica pentru gen (2p)

Exemplu de rezultat: “Sursa cea mai populara folosita de male http://t.co este si pentru ceilalti este folosita in 75% din cazuri de `female` si in rest de `other`.” ⁠
