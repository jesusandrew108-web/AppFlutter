// server.js
require('dotenv').config();
const express = require('express');
const axios = require('axios');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

const { CLIENT_ID, SECRET, PORT = 3000, PGUSER, PGPASSWORD, PGDATABASE, PGHOST, PGPORT } = process.env;

const pool = new Pool({
  user: PGUSER || 'postgres',
  host: PGHOST || 'localhost',
  database: PGDATABASE || 'Usuarios_Aplication',
  password: PGPASSWORD || 'tu_password',
  port: PGPORT || 5432,
});

// ------------------- ENDPOINTS DE USUARIOS -------------------

// Opcional: listar usuarios (para depurar)
app.get('/api/usuarios', async (req, res) => {
  try {
    const r = await pool.query('SELECT id, nombre, app, apm, email, role, is_verified, created_at FROM users ORDER BY id ASC');
    res.json(r.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error listando usuarios' });
  }
});

// Conteo de usuarios (decidir primer admin)
app.get('/api/usuarios/count', async (req, res) => {
  try {
    const r = await pool.query('SELECT COUNT(*)::int AS count FROM users');
    res.json({ count: r.rows[0].count });
  } catch (err) {
    console.error(err);
    res.json({ count: 0 });
  }
});

// Registro de usuario
app.post('/api/usuarios/register', async (req, res) => {
  const { nombre, app, apm, email, password, role } = req.body;

  try {
    const exists = await pool.query('SELECT 1 FROM users WHERE email = $1 LIMIT 1', [email]);
    if (exists.rows.length > 0) {
      return res.status(400).json({ error: 'Correo ya registrado' });
    }

    await pool.query(
      `INSERT INTO users (nombre, app, apm, email, password, role, is_verified, created_at)
       VALUES ($1,$2,$3,$4,$5,$6,$7,NOW())`,
      [nombre, app, apm, email, password, role, false]
    );

    res.status(201).json({
      message: 'Usuario creado',
      verified: false,
      role,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al registrar usuario' });
  }
});

// Login de usuario
app.post('/api/usuarios/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Usuario no encontrado' });
    }

    const user = result.rows[0];
    if (user.password !== password) {
      return res.status(401).json({ error: 'Contraseña incorrecta' });
    }

    res.json({
      role: user.role || 'cliente',
      verified: Boolean(user.is_verified), // fuerza true/false
      token: 'abc123', // pendiente JWT en producción
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en login' });
  }
});

// Verificar si correo existe
app.get('/api/usuarios/check-email', async (req, res) => {
  const { email } = req.query;
  try {
    const result = await pool.query('SELECT 1 FROM users WHERE email = $1 LIMIT 1', [email]);
    res.json({ exists: result.rows.length > 0 });
  } catch (err) {
    console.error(err);
    // Fallback seguro para no romper el cliente
    res.status(200).json({ exists: false });
  }
});

// ------------------- ENDPOINT DE PAYPAL -------------------
app.post('/create-order', async (req, res) => {
  try {
    const { cart, total } = req.body;
    const auth = Buffer.from(`${CLIENT_ID}:${SECRET}`).toString('base64');

    const tokenRes = await axios.post(
      'https://api-m.sandbox.paypal.com/v1/oauth2/token',
      'grant_type=client_credentials',
      { headers: { Authorization: `Basic ${auth}`, 'Content-Type': 'application/x-www-form-urlencoded' } }
    );
    const accessToken = tokenRes.data.access_token;

    const orderRes = await axios.post(
      'https://api-m.sandbox.paypal.com/v2/checkout/orders',
      {
        intent: 'CAPTURE',
        purchase_units: [{
          amount: { currency_code: 'USD', value: Number(total).toFixed(2) },
          items: cart.map(item => ({
            name: item.nombre_product,
            unit_amount: { currency_code: 'USD', value: Number(item.precio).toFixed(2) },
            quantity: String(item.cantidad),
          })),
        }],
        application_context: {
          return_url: 'https://success.com',
          cancel_url: 'https://cancel.com',
        },
      },
      { headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' } }
    );

    const approvalUrl = orderRes.data.links.find(link => link.rel === 'approve')?.href;
    res.json({ approvalUrl });
  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).json({ error: 'Error al crear orden de PayPal' });
  }
});

// ------------------- INICIO DEL SERVIDOR -------------------
app.listen(PORT, () => console.log(`Servidor corriendo en puerto ${PORT}`));
