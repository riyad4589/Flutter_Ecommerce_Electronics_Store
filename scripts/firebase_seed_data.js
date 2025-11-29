// Script pour importer les données dans Firebase Firestore
// Exécutez ce script avec Node.js après avoir configuré Firebase Admin SDK
// Ou copiez-collez les données manuellement dans la console Firebase

const admin = require('firebase-admin');

// Initialisez avec votre clé de service
// Téléchargez-la depuis: Console Firebase > Paramètres > Comptes de service > Générer une nouvelle clé privée
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// ============================================
// CATÉGORIES
// ============================================
const categories = [
  {
    id: "smartphones",
    name: "Smartphones",
    imageUrl: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400"
  },
  {
    id: "laptops",
    name: "Ordinateurs Portables",
    imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400"
  },
  {
    id: "tablets",
    name: "Tablettes",
    imageUrl: "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400"
  },
  {
    id: "headphones",
    name: "Casques & Écouteurs",
    imageUrl: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400"
  },
  {
    id: "watches",
    name: "Montres Connectées",
    imageUrl: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400"
  },
  {
    id: "accessories",
    name: "Accessoires",
    imageUrl: "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400"
  },
  {
    id: "gaming",
    name: "Gaming",
    imageUrl: "https://images.unsplash.com/photo-1612287230202-1ff1d85d1bdf?w=400"
  },
  {
    id: "cameras",
    name: "Appareils Photo",
    imageUrl: "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400"
  }
];

// ============================================
// PRODUITS
// ============================================
const products = [
  // SMARTPHONES
  {
    id: "iphone-15-pro-max",
    name: "iPhone 15 Pro Max",
    description: "Le smartphone le plus avancé d'Apple avec puce A17 Pro, écran Super Retina XDR 6.7 pouces, système de caméra pro 48MP et design en titane.",
    price: 1479.00,
    discountPrice: 1399.00,
    imageUrl: "https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400",
    categoryId: "smartphones",
    brand: "Apple",
    rating: 4.9,
    reviewCount: 1256,
    stock: 50,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "samsung-galaxy-s24-ultra",
    name: "Samsung Galaxy S24 Ultra",
    description: "Smartphone premium avec S Pen intégré, écran Dynamic AMOLED 2X 6.8 pouces, caméra 200MP et fonctionnalités Galaxy AI.",
    price: 1419.00,
    discountPrice: 1299.00,
    imageUrl: "https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400",
    categoryId: "smartphones",
    brand: "Samsung",
    rating: 4.8,
    reviewCount: 892,
    stock: 45,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "google-pixel-8-pro",
    name: "Google Pixel 8 Pro",
    description: "Le meilleur de Google avec puce Tensor G3, caméra avec Magic Eraser et 7 ans de mises à jour Android.",
    price: 1099.00,
    discountPrice: 999.00,
    imageUrl: "https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400",
    categoryId: "smartphones",
    brand: "Google",
    rating: 4.7,
    reviewCount: 654,
    stock: 35,
    isFeatured: false,
    createdAt: new Date()
  },
  {
    id: "xiaomi-14-ultra",
    name: "Xiaomi 14 Ultra",
    description: "Smartphone flagship avec optique Leica, Snapdragon 8 Gen 3 et charge rapide 90W.",
    price: 1299.00,
    discountPrice: 1149.00,
    imageUrl: "https://images.unsplash.com/photo-1574944985070-8f3ebc6b79d2?w=400",
    categoryId: "smartphones",
    brand: "Xiaomi",
    rating: 4.6,
    reviewCount: 423,
    stock: 30,
    isFeatured: false,
    createdAt: new Date()
  },

  // LAPTOPS
  {
    id: "macbook-pro-16-m3",
    name: "MacBook Pro 16\" M3 Max",
    description: "Ordinateur portable professionnel avec puce M3 Max, écran Liquid Retina XDR, 36GB RAM et jusqu'à 22h d'autonomie.",
    price: 3999.00,
    discountPrice: 3799.00,
    imageUrl: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400",
    categoryId: "laptops",
    brand: "Apple",
    rating: 4.9,
    reviewCount: 567,
    stock: 20,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "dell-xps-15",
    name: "Dell XPS 15",
    description: "Ultrabook premium avec Intel Core i9, écran OLED 3.5K, 32GB RAM et carte graphique RTX 4070.",
    price: 2499.00,
    discountPrice: 2299.00,
    imageUrl: "https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400",
    categoryId: "laptops",
    brand: "Dell",
    rating: 4.7,
    reviewCount: 423,
    stock: 25,
    isFeatured: false,
    createdAt: new Date()
  },
  {
    id: "asus-rog-zephyrus",
    name: "ASUS ROG Zephyrus G16",
    description: "PC portable gaming avec Intel Core i9, RTX 4090, écran 240Hz et clavier RGB personnalisable.",
    price: 2999.00,
    discountPrice: 2799.00,
    imageUrl: "https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=400",
    categoryId: "laptops",
    brand: "ASUS",
    rating: 4.8,
    reviewCount: 312,
    stock: 15,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "lenovo-thinkpad-x1",
    name: "Lenovo ThinkPad X1 Carbon",
    description: "Ultrabook professionnel léger avec Intel Core i7, écran 2.8K OLED, 16GB RAM et clavier légendaire.",
    price: 1899.00,
    discountPrice: null,
    imageUrl: "https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400",
    categoryId: "laptops",
    brand: "Lenovo",
    rating: 4.6,
    reviewCount: 278,
    stock: 30,
    isFeatured: false,
    createdAt: new Date()
  },

  // TABLETS
  {
    id: "ipad-pro-12-9",
    name: "iPad Pro 12.9\" M2",
    description: "Tablette professionnelle avec puce M2, écran Liquid Retina XDR, Face ID et compatibilité Apple Pencil 2.",
    price: 1329.00,
    discountPrice: 1249.00,
    imageUrl: "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400",
    categoryId: "tablets",
    brand: "Apple",
    rating: 4.8,
    reviewCount: 876,
    stock: 40,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "samsung-galaxy-tab-s9",
    name: "Samsung Galaxy Tab S9 Ultra",
    description: "Tablette Android premium avec écran AMOLED 14.6 pouces, S Pen inclus et mode DeX.",
    price: 1179.00,
    discountPrice: 1049.00,
    imageUrl: "https://images.unsplash.com/photo-1561154464-82e9adf32764?w=400",
    categoryId: "tablets",
    brand: "Samsung",
    rating: 4.7,
    reviewCount: 534,
    stock: 35,
    isFeatured: false,
    createdAt: new Date()
  },

  // HEADPHONES
  {
    id: "airpods-pro-2",
    name: "AirPods Pro 2",
    description: "Écouteurs sans fil avec réduction de bruit active, audio spatial personnalisé et boîtier MagSafe.",
    price: 279.00,
    discountPrice: 249.00,
    imageUrl: "https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=400",
    categoryId: "headphones",
    brand: "Apple",
    rating: 4.8,
    reviewCount: 2341,
    stock: 100,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "sony-wh1000xm5",
    name: "Sony WH-1000XM5",
    description: "Casque Bluetooth premium avec la meilleure réduction de bruit, 30h d'autonomie et audio Hi-Res.",
    price: 399.00,
    discountPrice: 349.00,
    imageUrl: "https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=400",
    categoryId: "headphones",
    brand: "Sony",
    rating: 4.9,
    reviewCount: 1876,
    stock: 60,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "bose-qc-ultra",
    name: "Bose QuietComfort Ultra",
    description: "Casque sans fil avec audio spatial immersif, réduction de bruit légendaire et confort premium.",
    price: 449.00,
    discountPrice: 399.00,
    imageUrl: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400",
    categoryId: "headphones",
    brand: "Bose",
    rating: 4.7,
    reviewCount: 967,
    stock: 45,
    isFeatured: false,
    createdAt: new Date()
  },

  // WATCHES
  {
    id: "apple-watch-ultra-2",
    name: "Apple Watch Ultra 2",
    description: "Montre connectée robuste avec GPS double fréquence, écran 3000 nits et jusqu'à 36h d'autonomie.",
    price: 899.00,
    discountPrice: 849.00,
    imageUrl: "https://images.unsplash.com/photo-1434494878577-86c23bcb06b9?w=400",
    categoryId: "watches",
    brand: "Apple",
    rating: 4.8,
    reviewCount: 743,
    stock: 35,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "samsung-galaxy-watch-6",
    name: "Samsung Galaxy Watch 6 Classic",
    description: "Montre connectée élégante avec lunette rotative, suivi santé avancé et intégration Galaxy.",
    price: 429.00,
    discountPrice: 379.00,
    imageUrl: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400",
    categoryId: "watches",
    brand: "Samsung",
    rating: 4.6,
    reviewCount: 534,
    stock: 50,
    isFeatured: false,
    createdAt: new Date()
  },
  {
    id: "garmin-fenix-7x",
    name: "Garmin Fenix 7X Pro",
    description: "Montre GPS multisports avec lampe torche LED, cartes TopoActive et jusqu'à 37 jours d'autonomie.",
    price: 899.00,
    discountPrice: null,
    imageUrl: "https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=400",
    categoryId: "watches",
    brand: "Garmin",
    rating: 4.9,
    reviewCount: 423,
    stock: 25,
    isFeatured: false,
    createdAt: new Date()
  },

  // GAMING
  {
    id: "ps5-console",
    name: "PlayStation 5",
    description: "Console de nouvelle génération avec SSD ultra-rapide, ray tracing et manette DualSense haptique.",
    price: 549.00,
    discountPrice: 499.00,
    imageUrl: "https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=400",
    categoryId: "gaming",
    brand: "Sony",
    rating: 4.9,
    reviewCount: 3421,
    stock: 20,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "xbox-series-x",
    name: "Xbox Series X",
    description: "La Xbox la plus puissante avec 12 téraflops, SSD 1TB et compatibilité 4 générations de jeux.",
    price: 499.00,
    discountPrice: 449.00,
    imageUrl: "https://images.unsplash.com/photo-1621259182978-fbf93132d53d?w=400",
    categoryId: "gaming",
    brand: "Microsoft",
    rating: 4.8,
    reviewCount: 2187,
    stock: 25,
    isFeatured: false,
    createdAt: new Date()
  },
  {
    id: "nintendo-switch-oled",
    name: "Nintendo Switch OLED",
    description: "Console hybride avec écran OLED 7 pouces, support ajustable et son amélioré.",
    price: 349.00,
    discountPrice: 319.00,
    imageUrl: "https://images.unsplash.com/photo-1612287230202-1ff1d85d1bdf?w=400",
    categoryId: "gaming",
    brand: "Nintendo",
    rating: 4.7,
    reviewCount: 1654,
    stock: 40,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "steam-deck-oled",
    name: "Steam Deck OLED",
    description: "PC gaming portable avec écran OLED HDR, APU AMD personnalisé et accès à votre bibliothèque Steam.",
    price: 569.00,
    discountPrice: null,
    imageUrl: "https://images.unsplash.com/photo-1640955014216-75201056c829?w=400",
    categoryId: "gaming",
    brand: "Valve",
    rating: 4.8,
    reviewCount: 876,
    stock: 15,
    isFeatured: false,
    createdAt: new Date()
  },

  // CAMERAS
  {
    id: "sony-a7-iv",
    name: "Sony Alpha A7 IV",
    description: "Appareil photo hybride plein format 33MP avec autofocus IA, vidéo 4K 60fps et stabilisation 5 axes.",
    price: 2499.00,
    discountPrice: 2299.00,
    imageUrl: "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400",
    categoryId: "cameras",
    brand: "Sony",
    rating: 4.9,
    reviewCount: 534,
    stock: 15,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "canon-eos-r6-ii",
    name: "Canon EOS R6 Mark II",
    description: "Hybride professionnel 24MP avec AF sujet intelligent, rafale 40 fps et vidéo 6K RAW.",
    price: 2499.00,
    discountPrice: null,
    imageUrl: "https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=400",
    categoryId: "cameras",
    brand: "Canon",
    rating: 4.8,
    reviewCount: 423,
    stock: 12,
    isFeatured: false,
    createdAt: new Date()
  },
  {
    id: "gopro-hero-12",
    name: "GoPro HERO12 Black",
    description: "Caméra d'action avec vidéo 5.3K, stabilisation HyperSmooth 6.0 et HDR amélioré.",
    price: 449.00,
    discountPrice: 399.00,
    imageUrl: "https://images.unsplash.com/photo-1564466809058-bf4114d55352?w=400",
    categoryId: "cameras",
    brand: "GoPro",
    rating: 4.6,
    reviewCount: 1234,
    stock: 50,
    isFeatured: false,
    createdAt: new Date()
  },

  // ACCESSORIES
  {
    id: "magsafe-charger",
    name: "Chargeur MagSafe Apple",
    description: "Chargeur sans fil magnétique 15W pour iPhone et AirPods avec alignement parfait.",
    price: 45.00,
    discountPrice: 39.00,
    imageUrl: "https://images.unsplash.com/photo-1622552245019-e04cfdea06a7?w=400",
    categoryId: "accessories",
    brand: "Apple",
    rating: 4.5,
    reviewCount: 2341,
    stock: 150,
    isFeatured: false,
    createdAt: new Date()
  },
  {
    id: "anker-powerbank",
    name: "Anker PowerCore 26800mAh",
    description: "Batterie externe haute capacité avec 3 ports USB et recharge rapide PowerIQ.",
    price: 65.00,
    discountPrice: 55.00,
    imageUrl: "https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400",
    categoryId: "accessories",
    brand: "Anker",
    rating: 4.7,
    reviewCount: 3456,
    stock: 200,
    isFeatured: true,
    createdAt: new Date()
  },
  {
    id: "logitech-mx-master",
    name: "Logitech MX Master 3S",
    description: "Souris sans fil premium avec défilement MagSpeed, capteur 8000 DPI et connexion multi-appareils.",
    price: 119.00,
    discountPrice: 99.00,
    imageUrl: "https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400",
    categoryId: "accessories",
    brand: "Logitech",
    rating: 4.8,
    reviewCount: 1876,
    stock: 80,
    isFeatured: false,
    createdAt: new Date()
  },
  {
    id: "samsung-t7-ssd",
    name: "Samsung T7 SSD 2TB",
    description: "SSD externe portable avec vitesses jusqu'à 1050 MB/s, cryptage AES 256 bits et design compact.",
    price: 219.00,
    discountPrice: 189.00,
    imageUrl: "https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=400",
    categoryId: "accessories",
    brand: "Samsung",
    rating: 4.8,
    reviewCount: 2134,
    stock: 70,
    isFeatured: false,
    createdAt: new Date()
  }
];

// ============================================
// FONCTION D'IMPORT
// ============================================
async function seedData() {
  console.log('🚀 Début de l\'import des données...\n');

  // Import des catégories
  console.log('📁 Import des catégories...');
  for (const category of categories) {
    await db.collection('categories').doc(category.id).set(category);
    console.log(`  ✅ ${category.name}`);
  }
  console.log(`\n✅ ${categories.length} catégories importées\n`);

  // Import des produits
  console.log('📦 Import des produits...');
  for (const product of products) {
    await db.collection('products').doc(product.id).set(product);
    console.log(`  ✅ ${product.name}`);
  }
  console.log(`\n✅ ${products.length} produits importés\n`);

  console.log('🎉 Import des données terminé!');
}

// ============================================
// CRÉATION UTILISATEUR ADMIN
// ============================================
async function createAdminUser() {
  console.log('👤 Création de l\'utilisateur admin...');
  
  try {
    // Créer l'utilisateur dans Firebase Auth
    const userRecord = await admin.auth().createUser({
      email: 'admin@gmail.com',
      password: 'admin123',
      displayName: 'admin',
      emailVerified: true
    });
    
    console.log(`  ✅ Utilisateur créé avec UID: ${userRecord.uid}`);
    
    // Ajouter les infos dans Firestore
    await db.collection('users').doc(userRecord.uid).set({
      id: userRecord.uid,
      name: 'admin',
      email: 'admin@gmail.com',
      username: 'admin',
      profileImage: '',
      isAdmin: true,
      createdAt: new Date(),
      updatedAt: new Date()
    });
    
    console.log('  ✅ Profil admin ajouté dans Firestore\n');
    return userRecord;
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      console.log('  ⚠️ L\'utilisateur admin existe déjà\n');
    } else {
      throw error;
    }
  }
}

// Exécuter l'import complet
async function runAll() {
  await seedData();
  await createAdminUser();
  console.log('🎉 Tout est prêt!');
  process.exit(0);
}

runAll().catch(console.error);
