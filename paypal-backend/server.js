require('dotenv').config();
const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PAYPAL_API = 'https://api-m.sandbox.paypal.com';
const { PAYPAL_CLIENT_ID, PAYPAL_SECRET } = process.env;

async function getAccessToken() {
  try {
    const response = await axios({
      url: `${PAYPAL_API}/v1/oauth2/token`,
      method: 'post',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      auth: {
        username: PAYPAL_CLIENT_ID,
        password: PAYPAL_SECRET,
      },
      data: 'grant_type=client_credentials',
    });
    return response.data.access_token;
  } catch (error) {
    console.error('Error al obtener token de PayPal:', error.response?.data || error.message);
    throw new Error('No se pudo obtener el token de acceso');
  }
}
app.post('/send-otp', async (req, res) => {
  const { email } = req.body;
  const otp = Math.floor(100000 + Math.random() * 900000);
  // Guarda el OTP en memoria o base de datos
  // Envía por correo con nodemailer
  res.json({ message: 'OTP enviado' });
});

app.post('/verify-otp', async (req, res) => {
  const { email, otp } = req.body;
  // Verifica que el OTP coincida
  res.json({ message: 'OTP verificado' });
});


app.post('/create-order', async (req, res) => {
  try {
    const { cart, total } = req.body;

    if (!PAYPAL_CLIENT_ID || !PAYPAL_SECRET) {
      return res.status(500).json({ error: 'Credenciales de PayPal no configuradas' });
    }

    const accessToken = await getAccessToken();

    const order = await axios.post(
      `${PAYPAL_API}/v2/checkout/orders`,
      {
        intent: 'CAPTURE',
        purchase_units: [{
          amount: {
            currency_code: 'USD',
            value: total.toFixed(2),
          },
        }],
        application_context: {
          return_url: 'https://success.com',
          cancel_url: 'https://cancel.com',
        },
      },
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
      }
    );

    const approvalUrl = order.data.links.find(link => link.rel === 'approve')?.href;

    if (!approvalUrl) {
      throw new Error('No se encontró la URL de aprobación');
    }

    res.json({ approvalUrl });
  } catch (error) {
    console.error('Error al crear orden PayPal:', error.response?.data || error.message);
    res.status(500).json({ error: 'No se pudo crear la orden' });
  }
});

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => console.log(`Servidor corriendo en puerto ${PORT}`));
