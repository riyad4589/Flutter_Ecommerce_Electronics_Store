const express = require('express');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = 3000;
const JWT_SECRET = 'your_super_secret_key';

app.use(express.json());

let users = [];
const products = [
    // Catégorie Électronique
    {
        id: 'p1',
        name: 'iPhone 15 Pro Max',
        description: 'Le dernier smartphone d\'Apple avec puce A17 Pro et écran Super Retina XDR.',
        price: 13999.00,
        discountPrice: 12999.00,
        imageUrl: 'https://images.unsplash.com/photo-1592286927505-86db0a1c9a57?w=500',
        categoryId: 'electronique',
        brand: 'Apple',
        rating: 4.9,
        reviewCount: 245,
    },
    {
        id: 'p2',
        name: 'Samsung Galaxy S24 Ultra',
        description: 'Smartphone premium avec S Pen intégré et zoom 100x.',
        price: 12499.00,
        discountPrice: 11999.00,
        imageUrl: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=500',
        categoryId: 'electronique',
        brand: 'Samsung',
        rating: 4.8,
        reviewCount: 198,
    },
    {
        id: 'p3',
        name: 'MacBook Pro M3 16"',
        description: 'Ordinateur portable professionnel avec puce M3 Max et écran Liquid Retina XDR.',
        price: 29999.00,
        discountPrice: 27999.00,
        imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500',
        categoryId: 'electronique',
        brand: 'Apple',
        rating: 4.9,
        reviewCount: 156,
    },
    {
        id: 'p4',
        name: 'Dell XPS 15',
        description: 'PC portable haut de gamme avec écran InfinityEdge 4K.',
        price: 18999.00,
        discountPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=500',
        categoryId: 'electronique',
        brand: 'Dell',
        rating: 4.7,
        reviewCount: 134,
    },
    {
        id: 'p5',
        name: 'iPad Pro 12.9"',
        description: 'Tablette professionnelle avec puce M2 et écran Liquid Retina XDR.',
        price: 11999.00,
        discountPrice: 10999.00,
        imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500',
        categoryId: 'electronique',
        brand: 'Apple',
        rating: 4.8,
        reviewCount: 189,
    },
    {
        id: 'p6',
        name: 'Sony WH-1000XM5',
        description: 'Casque sans fil à réduction de bruit active de référence.',
        price: 3999.00,
        discountPrice: 3499.00,
        imageUrl: 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=500',
        categoryId: 'electronique',
        brand: 'Sony',
        rating: 4.8,
        reviewCount: 412,
    },
    {
        id: 'p7',
        name: 'Apple AirPods Pro 2',
        description: 'Écouteurs sans fil avec réduction de bruit adaptative.',
        price: 2799.00,
        discountPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=500',
        categoryId: 'electronique',
        brand: 'Apple',
        rating: 4.7,
        reviewCount: 523,
    },
    {
        id: 'p8',
        name: 'Canon EOS R6 Mark II',
        description: 'Appareil photo hybride plein format 24 MP avec autofocus intelligent.',
        price: 27999.00,
        discountPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500',
        categoryId: 'electronique',
        brand: 'Canon',
        rating: 4.9,
        reviewCount: 87,
    },

    // Catégorie Mode
    {
        id: 'p9',
        name: 'Nike Air Max 270',
        description: 'Baskets confortables avec amorti Max Air pour un style urbain.',
        price: 1599.00,
        discountPrice: 1299.00,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
        categoryId: 'mode',
        brand: 'Nike',
        rating: 4.6,
        reviewCount: 678,
    },
    {
        id: 'p10',
        name: 'Adidas Ultraboost 23',
        description: 'Chaussures de running avec technologie Boost pour le confort.',
        price: 1899.00,
        discountPrice: 1699.00,
        imageUrl: 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=500',
        categoryId: 'mode',
        brand: 'Adidas',
        rating: 4.7,
        reviewCount: 543,
    },
    {
        id: 'p11',
        name: 'Levi\'s 501 Original Jeans',
        description: 'Jean classique coupe droite, un intemporel de la mode.',
        price: 899.00,
        discountPrice: 749.00,
        imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=500',
        categoryId: 'mode',
        brand: 'Levi\'s',
        rating: 4.5,
        reviewCount: 892,
    },
    {
        id: 'p12',
        name: 'Ray-Ban Aviator Classic',
        description: 'Lunettes de soleil iconiques avec verres polarisés.',
        price: 1599.00,
        discountPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500',
        categoryId: 'mode',
        brand: 'Ray-Ban',
        rating: 4.8,
        reviewCount: 1234,
    },
    {
        id: 'p13',
        name: 'Polo Ralph Lauren',
        description: 'Polo classique en coton piqué avec logo brodé.',
        price: 799.00,
        discountPrice: 649.00,
        imageUrl: 'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=500',
        categoryId: 'mode',
        brand: 'Ralph Lauren',
        rating: 4.6,
        reviewCount: 456,
    },
    {
        id: 'p14',
        name: 'Sac à dos Eastpak',
        description: 'Sac à dos résistant avec compartiment ordinateur 15".',
        price: 599.00,
        discountPrice: 499.00,
        imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500',
        categoryId: 'mode',
        brand: 'Eastpak',
        rating: 4.7,
        reviewCount: 789,
    },

    // Catégorie Maison
    {
        id: 'p15',
        name: 'Aspirateur Robot Roomba',
        description: 'Robot aspirateur intelligent avec navigation avancée.',
        price: 4999.00,
        discountPrice: 4499.00,
        imageUrl: 'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=500',
        categoryId: 'maison',
        brand: 'iRobot',
        rating: 4.6,
        reviewCount: 634,
    },
    {
        id: 'p16',
        name: 'Nespresso Vertuo',
        description: 'Machine à café avec système d\'extraction centrifuge.',
        price: 1899.00,
        discountPrice: 1599.00,
        imageUrl: 'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=500',
        categoryId: 'maison',
        brand: 'Nespresso',
        rating: 4.7,
        reviewCount: 892,
    },
    {
        id: 'p17',
        name: 'Dyson V15 Detect',
        description: 'Aspirateur sans fil avec laser qui révèle la poussière invisible.',
        price: 6999.00,
        discountPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=500',
        categoryId: 'maison',
        brand: 'Dyson',
        rating: 4.8,
        reviewCount: 423,
    },
    {
        id: 'p18',
        name: 'Lampe LED Philips Hue',
        description: 'Ampoule connectée avec 16 millions de couleurs.',
        price: 599.00,
        discountPrice: 499.00,
        imageUrl: 'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=500',
        categoryId: 'maison',
        brand: 'Philips',
        rating: 4.5,
        reviewCount: 1567,
    },
    {
        id: 'p19',
        name: 'Mixeur Vitamix',
        description: 'Blender professionnel ultra-puissant 2000W.',
        price: 5499.00,
        discountPrice: 4999.00,
        imageUrl: 'https://images.unsplash.com/photo-1585515320310-259814833e62?w=500',
        categoryId: 'maison',
        brand: 'Vitamix',
        rating: 4.9,
        reviewCount: 234,
    },
    {
        id: 'p20',
        name: 'Canapé 3 Places',
        description: 'Canapé convertible en tissu avec coffre de rangement.',
        price: 7999.00,
        discountPrice: 6999.00,
        imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500',
        categoryId: 'maison',
        brand: 'IKEA',
        rating: 4.4,
        reviewCount: 345,
    },

    // Catégorie Sports
    {
        id: 'p21',
        name: 'Tapis de Course ProForm',
        description: 'Tapis de course pliable avec écran tactile et programmes intégrés.',
        price: 8999.00,
        discountPrice: 7999.00,
        imageUrl: 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=500',
        categoryId: 'sports',
        brand: 'ProForm',
        rating: 4.6,
        reviewCount: 289,
    },
    {
        id: 'p22',
        name: 'Vélo Électrique',
        description: 'VTT électrique avec batterie longue durée et suspension complète.',
        price: 15999.00,
        discountPrice: 14499.00,
        imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500',
        categoryId: 'sports',
        brand: 'Decathlon',
        rating: 4.7,
        reviewCount: 456,
    },
    {
        id: 'p23',
        name: 'Haltères Réglables 20kg',
        description: 'Set d\'haltères ajustables pour musculation à domicile.',
        price: 2999.00,
        discountPrice: 2499.00,
        imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=500',
        categoryId: 'sports',
        brand: 'Bowflex',
        rating: 4.8,
        reviewCount: 678,
    },
    {
        id: 'p24',
        name: 'Ballon de Basketball Wilson',
        description: 'Ballon officiel de compétition en cuir composite.',
        price: 599.00,
        discountPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=500',
        categoryId: 'sports',
        brand: 'Wilson',
        rating: 4.7,
        reviewCount: 892,
    },
    {
        id: 'p25',
        name: 'Tapis de Yoga Premium',
        description: 'Tapis antidérapant en TPE écologique 6mm d\'épaisseur.',
        price: 499.00,
        discountPrice: 399.00,
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500',
        categoryId: 'sports',
        brand: 'Manduka',
        rating: 4.6,
        reviewCount: 1234,
    },
    {
        id: 'p26',
        name: 'Montre Garmin Fenix 7',
        description: 'Montre GPS multisport avec cartographie et suivi santé avancé.',
        price: 5999.00,
        discountPrice: 5499.00,
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500',
        categoryId: 'sports',
        brand: 'Garmin',
        rating: 4.8,
        reviewCount: 567,
    },
    {
        id: 'p27',
        name: 'Raquette de Tennis Wilson',
        description: 'Raquette pro avec cordage hybride et grip confort.',
        price: 1899.00,
        discountPrice: 1699.00,
        imageUrl: 'https://images.unsplash.com/photo-1622163642998-1ea32b0bbc67?w=500',
        categoryId: 'sports',
        brand: 'Wilson',
        rating: 4.7,
        reviewCount: 234,
    },
    {
        id: 'p28',
        name: 'Gants de Boxe Everlast',
        description: 'Gants de boxe professionnels en cuir véritable 16oz.',
        price: 899.00,
        discountPrice: 749.00,
        imageUrl: 'https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?w=500',
        categoryId: 'sports',
        brand: 'Everlast',
        rating: 4.5,
        reviewCount: 456,
    },
];

const categories = [
    { id: 'electronique', name: 'Électronique', imageUrl: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=200' },
    { id: 'mode', name: 'Mode', imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=200' },
    { id: 'maison', name: 'Maison', imageUrl: 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=200' },
    { id: 'sports', name: 'Sports', imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=200' },
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
