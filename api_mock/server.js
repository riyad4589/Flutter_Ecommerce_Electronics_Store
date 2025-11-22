const express = require('express');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = 3000;
const JWT_SECRET = 'your_super_secret_key';

app.use(express.json());

let users = [];
const products = [
    // Catégorie Smartphones
    {
        id: 'p1',
        name: 'iPhone 15 Pro Max',
        description: 'Smartphone Apple avec puce A17 Pro, écran Super Retina XDR 6.7", caméra 48MP et design en titane.',
        price: 13999.00,
        discountPrice: 12999.00,
        imageUrl: 'https://images.unsplash.com/photo-1592286927505-86db0a1c9a57?w=500',
        categoryId: 'smartphones',
        brand: 'Apple',
        rating: 4.9,
        reviewCount: 245,
    },
    {
        id: 'p2',
        name: 'Samsung Galaxy S24 Ultra',
        description: 'Smartphone premium avec S Pen intégré, zoom optique 10x, écran AMOLED 6.8" et caméra 200MP.',
        price: 12499.00,
        discountPrice: 11999.00,
        imageUrl: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=500',
        categoryId: 'smartphones',
        brand: 'Samsung',
        rating: 4.8,
        reviewCount: 198,
    },
    {
        id: 'p3',
        name: 'Google Pixel 8 Pro',
        description: 'Smartphone Google avec IA avancée, caméra 50MP, écran LTPO OLED et processeur Tensor G3.',
        price: 9999.00,
        discountPrice: 8999.00,
        imageUrl: 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500',
        categoryId: 'smartphones',
        brand: 'Google',
        rating: 4.7,
        reviewCount: 156,
    },
    {
        id: 'p4',
        name: 'Xiaomi 14 Pro',
        description: 'Smartphone haut de gamme avec Snapdragon 8 Gen 3, charge rapide 120W et caméra Leica.',
        price: 7999.00,
        discountPrice: 7499.00,
        imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500',
        categoryId: 'smartphones',
        brand: 'Xiaomi',
        rating: 4.6,
        reviewCount: 189,
    },

    // Catégorie Ordinateurs
    {
        id: 'p5',
        name: 'MacBook Pro M3 16"',
        description: 'Laptop professionnel avec puce M3 Max, 36GB RAM, écran Liquid Retina XDR et autonomie 22h.',
        price: 29999.00,
        discountPrice: 27999.00,
        imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500',
        categoryId: 'ordinateurs',
        brand: 'Apple',
        rating: 4.9,
        reviewCount: 134,
    },
    {
        id: 'p6',
        name: 'Dell XPS 15',
        description: 'PC portable premium avec Intel Core i9, NVIDIA RTX 4060, écran OLED 4K et design InfinityEdge.',
        price: 18999.00,
        discountPrice: 17499.00,
        imageUrl: 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=500',
        categoryId: 'ordinateurs',
        brand: 'Dell',
        rating: 4.7,
        reviewCount: 112,
    },
    {
        id: 'p7',
        name: 'Lenovo ThinkPad X1 Carbon',
        description: 'Ultrabook professionnel léger 1.12kg, Intel Core i7, 32GB RAM et certification militaire MIL-STD.',
        price: 15999.00,
        discountPrice: 14999.00,
        imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500',
        categoryId: 'ordinateurs',
        brand: 'Lenovo',
        rating: 4.8,
        reviewCount: 98,
    },
    {
        id: 'p8',
        name: 'ASUS ROG Strix G16',
        description: 'PC gaming avec Intel Core i9, NVIDIA RTX 4070, écran 240Hz et refroidissement liquid metal.',
        price: 19999.00,
        discountPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=500',
        categoryId: 'ordinateurs',
        brand: 'ASUS',
        rating: 4.8,
        reviewCount: 156,
    },

    // Catégorie Tablettes
    {
        id: 'p9',
        name: 'iPad Pro 12.9" M2',
        description: 'Tablette professionnelle avec puce M2, écran mini-LED, Apple Pencil 2 et Magic Keyboard.',
        price: 11999.00,
        discountPrice: 10999.00,
        imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500',
        categoryId: 'tablettes',
        brand: 'Apple',
        rating: 4.8,
        reviewCount: 223,
    },
    {
        id: 'p10',
        name: 'Samsung Galaxy Tab S9 Ultra',
        description: 'Tablette Android 14.6", S Pen inclus, résistance IP68 et écran AMOLED 120Hz.',
        price: 9999.00,
        discountPrice: 8999.00,
        imageUrl: 'https://images.unsplash.com/photo-1585790050230-5dd28404f8f4?w=500',
        categoryId: 'tablettes',
        brand: 'Samsung',
        rating: 4.7,
        reviewCount: 167,
    },
    {
        id: 'p11',
        name: 'Microsoft Surface Pro 9',
        description: 'Tablette 2-en-1 avec Intel Core i7, écran PixelSense 13", clavier détachable et stylet inclus.',
        price: 12999.00,
        discountPrice: 11499.00,
        imageUrl: 'https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=500',
        categoryId: 'tablettes',
        brand: 'Microsoft',
        rating: 4.6,
        reviewCount: 134,
    },

    // Catégorie Audio
    {
        id: 'p12',
        name: 'Sony WH-1000XM5',
        description: 'Casque sans fil premium avec réduction de bruit adaptative AI, 30h d\'autonomie et audio Hi-Res.',
        price: 3999.00,
        discountPrice: 3499.00,
        imageUrl: 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=500',
        categoryId: 'audio',
        brand: 'Sony',
        rating: 4.8,
        reviewCount: 412,
    },
    {
        id: 'p13',
        name: 'Apple AirPods Pro 2',
        description: 'Écouteurs sans fil avec réduction de bruit adaptative, audio spatial et boîtier MagSafe USB-C.',
        price: 2799.00,
        discountPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=500',
        categoryId: 'audio',
        brand: 'Apple',
        rating: 4.7,
        reviewCount: 523,
    },
    {
        id: 'p14',
        name: 'Bose QuietComfort Ultra',
        description: 'Casque Bluetooth avec réduction de bruit immersive, audio spatial CustomTune et 24h d\'autonomie.',
        price: 4499.00,
        discountPrice: 3999.00,
        imageUrl: 'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=500',
        categoryId: 'audio',
        brand: 'Bose',
        rating: 4.8,
        reviewCount: 298,
    },
    {
        id: 'p15',
        name: 'JBL Flip 6',
        description: 'Enceinte Bluetooth portable étanche IP67, son stéréo puissant et 12h d\'autonomie.',
        price: 1299.00,
        discountPrice: 999.00,
        imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500',
        categoryId: 'audio',
        brand: 'JBL',
        rating: 4.6,
        reviewCount: 678,
    },

    // Catégorie Photo & Vidéo
    {
        id: 'p16',
        name: 'Canon EOS R6 Mark II',
        description: 'Appareil photo hybride 24MP plein format, autofocus intelligent Dual Pixel II et vidéo 4K 60fps.',
        price: 27999.00,
        discountPrice: 25999.00,
        imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500',
        categoryId: 'photo_video',
        brand: 'Canon',
        rating: 4.9,
        reviewCount: 87,
    },
    {
        id: 'p17',
        name: 'Sony Alpha 7 IV',
        description: 'Appareil hybride 33MP, stabilisation 5 axes, autofocus eye-AF et vidéo 4K 60fps 10-bit.',
        price: 24999.00,
        discountPrice: 22999.00,
        imageUrl: 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=500',
        categoryId: 'photo_video',
        brand: 'Sony',
        rating: 4.8,
        reviewCount: 123,
    },
    {
        id: 'p18',
        name: 'DJI Mavic 3 Pro',
        description: 'Drone professionnel avec triple caméra Hasselblad, autonomie 43 min et détection d\'obstacles 360°.',
        price: 19999.00,
        discountPrice: 17999.00,
        imageUrl: 'https://images.unsplash.com/photo-1473968512647-3e447244af8f?w=500',
        categoryId: 'photo_video',
        brand: 'DJI',
        rating: 4.9,
        reviewCount: 201,
    },
    {
        id: 'p19',
        name: 'GoPro HERO 12 Black',
        description: 'Caméra d\'action 5.3K, stabilisation HyperSmooth 6.0, étanche 10m et écran tactile avant/arrière.',
        price: 4999.00,
        discountPrice: 4499.00,
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500',
        categoryId: 'photo_video',
        brand: 'GoPro',
        rating: 4.7,
        reviewCount: 345,
    },

    // Catégorie Gaming
    {
        id: 'p20',
        name: 'PlayStation 5 Slim',
        description: 'Console de jeu nouvelle génération avec SSD 1TB, ray-tracing et manette DualSense.',
        price: 4999.00,
        discountPrice: 4499.00,
        imageUrl: 'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=500',
        categoryId: 'gaming',
        brand: 'Sony',
        rating: 4.9,
        reviewCount: 567,
    },
    {
        id: 'p21',
        name: 'Xbox Series X',
        description: 'Console Microsoft 4K 120fps, SSD 1TB, ray-tracing et rétrocompatibilité complète.',
        price: 4799.00,
        discountPrice: 4299.00,
        imageUrl: 'https://images.unsplash.com/photo-1621259182978-fbf93132d53d?w=500',
        categoryId: 'gaming',
        brand: 'Microsoft',
        rating: 4.8,
        reviewCount: 489,
    },
    {
        id: 'p22',
        name: 'Nintendo Switch OLED',
        description: 'Console hybride avec écran OLED 7", 64GB de stockage et station d\'accueil améliorée.',
        price: 3499.00,
        discountPrice: 2999.00,
        imageUrl: 'https://images.unsplash.com/photo-1578303512597-81e6cc155b3e?w=500',
        categoryId: 'gaming',
        brand: 'Nintendo',
        rating: 4.7,
        reviewCount: 634,
    },
    {
        id: 'p23',
        name: 'Steam Deck OLED',
        description: 'Console portable PC gaming avec écran OLED HDR, SSD 1TB et compatibilité Steam.',
        price: 5999.00,
        discountPrice: 5499.00,
        imageUrl: 'https://images.unsplash.com/photo-1592840496694-26d035b52b48?w=500',
        categoryId: 'gaming',
        brand: 'Valve',
        rating: 4.8,
        reviewCount: 312,
    },

    // Catégorie Accessoires
    {
        id: 'p24',
        name: 'Logitech MX Master 3S',
        description: 'Souris ergonomique sans fil avec 8000 DPI, défilement MagSpeed et batterie 70 jours.',
        price: 1099.00,
        discountPrice: 999.00,
        imageUrl: 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=500',
        categoryId: 'accessoires',
        brand: 'Logitech',
        rating: 4.8,
        reviewCount: 789,
    },
    {
        id: 'p25',
        name: 'Keychron K8 Pro',
        description: 'Clavier mécanique sans fil 75%, switches hot-swap, RGB et connexion multi-appareils.',
        price: 1499.00,
        discountPrice: 1299.00,
        imageUrl: 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500',
        categoryId: 'accessoires',
        brand: 'Keychron',
        rating: 4.7,
        reviewCount: 456,
    },
    {
        id: 'p26',
        name: 'Anker PowerCore 26800',
        description: 'Batterie externe 26800mAh avec charge rapide PowerIQ 3.0 et 3 ports USB.',
        price: 699.00,
        discountPrice: 599.00,
        imageUrl: 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=500',
        categoryId: 'accessoires',
        brand: 'Anker',
        rating: 4.6,
        reviewCount: 1234,
    },
    {
        id: 'p27',
        name: 'SanDisk Extreme Pro 1TB',
        description: 'SSD externe NVMe 1TB, vitesse 2000 MB/s, résistant IP55 et chiffrement matériel.',
        price: 1999.00,
        discountPrice: 1799.00,
        imageUrl: 'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=500',
        categoryId: 'accessoires',
        brand: 'SanDisk',
        rating: 4.8,
        reviewCount: 567,
    },
    {
        id: 'p28',
        name: 'Belkin 3-in-1 MagSafe',
        description: 'Chargeur sans fil MagSafe pour iPhone, Apple Watch et AirPods, charge rapide 15W.',
        price: 1299.00,
        discountPrice: 1099.00,
        imageUrl: 'https://images.unsplash.com/photo-1591290619762-c588f5313d3d?w=500',
        categoryId: 'accessoires',
        brand: 'Belkin',
        rating: 4.7,
        reviewCount: 423,
    },
];

const categories = [
    { id: 'smartphones', name: 'Smartphones', imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=200' },
    { id: 'ordinateurs', name: 'Ordinateurs', imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=200' },
    { id: 'tablettes', name: 'Tablettes', imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=200' },
    { id: 'audio', name: 'Audio', imageUrl: 'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=200' },
    { id: 'photo_video', name: 'Photo & Vidéo', imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=200' },
    { id: 'gaming', name: 'Gaming', imageUrl: 'https://images.unsplash.com/photo-1592840496694-26d035b52b48?w=200' },
    { id: 'accessoires', name: 'Accessoires', imageUrl: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=200' },
];

let carts = {};
let orders = [];

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token == null) return res.sendStatus(401);

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.sendStatus(403);
        req.user = user;
        next();
    });
};

// AUTH ROUTES
app.post('/api/v1/auth/register', (req, res) => {
    const { name, email, password, username } = req.body;

    if (!name || !email || !password) {
        return res.status(400).json({ message: 'Veuillez remplir tous les champs.' });
    }
    if (users.find(u => u.email === email)) {
        return res.status(409).json({ message: 'Cet email est déjà enregistré.' });
    }
    if (username && users.find(u => u.username === username)) {
        return res.status(409).json({ message: 'Ce nom d\'utilisateur est déjà pris.' });
    }

    const newUser = { 
        id: (users.length + 1).toString(), 
        name, 
        email, 
        password,
        username: username || email.split('@')[0] // Generate username from email if not provided
    };
    users.push(newUser);

    const token = jwt.sign({ id: newUser.id, email: newUser.email }, JWT_SECRET, { expiresIn: '1h' });

    res.status(201).json({
        message: 'Utilisateur enregistré avec succès.',
        data: {
            id: newUser.id,
            name: newUser.name,
            email: newUser.email,
            username: newUser.username,
            token,
        },
    });
});

app.post('/api/v1/auth/login', (req, res) => {
    const { username, email, password } = req.body;
    
    console.log('Login attempt:', { username, email, password });
    console.log('Existing users:', users.map(u => ({ id: u.id, username: u.username, email: u.email })));
    
    // Support both username and email for login
    const user = users.find(u => {
        if (username) {
            return u.username === username && u.password === password;
        } else if (email) {
            return u.email === email && u.password === password;
        }
        return false;
    });

    if (!user) {
        console.log('User not found or password mismatch');
        return res.status(401).json({ message: 'Identifiants incorrects.' });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '1h' });

    res.status(200).json({
        message: 'Connexion réussie.',
        data: {
            id: user.id,
            name: user.name,
            email: user.email,
            username: user.username,
            token,
        },
    });
});

// USER PROFILE ROUTES
app.patch('/api/v1/users/:id', authenticateToken, (req, res) => {
    const userId = req.params.id;
    const { name, email } = req.body;

    // Verify user is updating their own profile
    if (req.user.id !== userId) {
        return res.status(403).json({ message: 'Vous ne pouvez modifier que votre propre profil.' });
    }

    const userIndex = users.findIndex(u => u.id === userId);
    if (userIndex === -1) {
        return res.status(404).json({ message: 'Utilisateur non trouvé.' });
    }

    // Check if new email is already taken by another user
    if (email && email !== users[userIndex].email) {
        const emailExists = users.find(u => u.email === email && u.id !== userId);
        if (emailExists) {
            return res.status(409).json({ message: 'Cet email est déjà utilisé.' });
        }
    }

    // Update user data
    if (name) users[userIndex].name = name;
    if (email) users[userIndex].email = email;

    res.status(200).json({
        message: 'Profil mis à jour avec succès.',
        data: {
            id: users[userIndex].id,
            name: users[userIndex].name,
            email: users[userIndex].email,
            username: users[userIndex].username,
        },
    });
});

// PRODUCT ROUTES
app.get('/api/v1/products', (req, res) => {
    res.status(200).json({
        message: 'Liste des produits.',
        data: products,
    });
});

app.get('/api/v1/products/:id', (req, res) => {
    const productId = req.params.id;
    const product = products.find(p => p.id === productId);

    if (!product) {
        return res.status(404).json({ message: 'Produit non trouvé.' });
    }
    res.status(200).json({
        message: 'Détails du produit.',
        data: product,
    });
});

app.get('/api/v1/categories', (req, res) => {
    res.status(200).json({
        message: 'Liste des catégories.',
        data: categories,
    });
});

// CART ROUTES
app.get('/api/v1/cart', authenticateToken, (req, res) => {
    const userId = req.user.id;
    const userCart = carts[userId] || [];
    res.status(200).json({
        message: 'Panier de l\'utilisateur.',
        data: userCart,
    });
});

app.post('/api/v1/cart/add', authenticateToken, (req, res) => {
    const userId = req.user.id;
    const { productId, quantity } = req.body;

    if (!productId || !quantity || quantity < 1) {
        return res.status(400).json({ message: 'ID du produit et quantité requis.' });
    }

    const product = products.find(p => p.id === productId);
    if (!product) {
        return res.status(404).json({ message: 'Produit non trouvé.' });
    }

    carts[userId] = carts[userId] || [];
    const existingItemIndex = carts[userId].findIndex(item => item.product.id === productId);

    if (existingItemIndex > -1) {
        carts[userId][existingItemIndex].quantity += quantity;
    } else {
        carts[userId].push({ product, quantity });
    }

    res.status(200).json({
        message: 'Produit ajouté au panier.',
        data: carts[userId],
    });
});

// ORDER ROUTES
app.post('/api/v1/orders', authenticateToken, (req, res) => {
    const userId = req.user.id;
    const { items, totalAmount } = req.body;

    if (!items || items.length === 0) {
        return res.status(400).json({ message: 'Le panier est vide.' });
    }

    const newOrder = {
        id: `ord-${orders.length + 1}`,
        userId,
        items,
        totalAmount,
        orderDate: new Date().toISOString(),
        status: 'pending',
    };
    orders.push(newOrder);

    // Vider le panier du serveur si il existe
    if (carts[userId]) {
        carts[userId] = [];
    }

    res.status(201).json({
        message: 'Commande créée avec succès.',
        data: newOrder,
    });
});

app.get('/api/v1/orders', authenticateToken, (req, res) => {
    const userId = req.user.id;
    const userOrders = orders.filter(order => order.userId === userId);
    res.status(200).json({
        message: 'Historique des commandes.',
        data: userOrders,
    });
});

// Route pour visualiser toutes les données de la BD (debug)
app.get('/api/v1/debug/database', (req, res) => {
    res.status(200).json({
        message: 'Données de la base de données',
        data: {
            users: users.map(u => ({
                id: u.id,
                name: u.name,
                email: u.email,
                registeredAt: u.registeredAt
            })),
            products: products,
            carts: carts,
            orders: orders,
            statistics: {
                totalUsers: users.length,
                totalProducts: products.length,
                totalOrders: orders.length,
                totalCarts: Object.keys(carts).length
            }
        }
    });
});

// Route pour vider les tables (debug)
app.post('/api/v1/debug/clear', (req, res) => {
    const { tables } = req.body;
    
    if (!tables || !Array.isArray(tables)) {
        return res.status(400).json({ message: 'Veuillez spécifier les tables à vider' });
    }

    let cleared = [];
    
    if (tables.includes('users')) {
        users = [];
        cleared.push('users');
    }
    
    if (tables.includes('orders')) {
        orders = [];
        cleared.push('orders');
    }
    
    if (tables.includes('carts')) {
        carts = {};
        cleared.push('carts');
    }
    
    res.status(200).json({
        message: 'Tables vidées avec succès',
        cleared: cleared
    });
});

app.listen(PORT, () => {
    console.log(`API Mock server running on http://localhost:${PORT}`);
    console.log(`Users: ${JSON.stringify(users)}`);
    console.log(`Debug endpoint: http://localhost:${PORT}/api/v1/debug/database`);
});
