import express from 'express';
import getRawBody from 'raw-body';
import dotenv from 'dotenv';

import { queryClickHouse } from './clickhouse';

dotenv.config();

const app = express();

// Raw request logging before any parsing
app.use(async (req, res, next) => {  
  
  console.log('Webhook received:', {
    url: req.url,
    contentType: req.headers['content-type'],
    headers: req.headers
  });


  if (req.headers['goldsky-webhook-secret'] !== process.env.WEBHOOK_SECRET) {
    console.log('Webhook unauthorized');
    res.status(401).json({ error: 'Unauthorized' });
    return;
  }
  
  console.log('Webhook authorized');
  next();
});

// Root handler that accepts anything
app.post('/', async (req, res) => {
  console.log('Webhook received:', {
    contentType: req.headers['content-type'],
    body: req.body,
    headers: req.headers
  });
  
  try {
    const rawBody = await getRawBody(req, {
      length: req.headers['content-length'],
      limit: '1mb',
      encoding: true
    });
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] Raw body:`, rawBody);
    req.body = JSON.parse(rawBody);
    const op = req.body.op;
    if (op === 'INSERT') {
      const id = req.body.query_id;
      const message = req.body.data.new.message;
      console.log('query id:', id);
      console.log('query:', message);
      const data = await queryClickHouse(message);
      console.log('data:', data);
    } else {
      console.log('Op:', op);
    }
  } catch (e) {
    console.error('Error reading raw body:', e);
  }

  res.status(200).json({ received: true });
});

app.listen(process.env.PORT || 3000, () => {
  console.log(`Server running on port ${process.env.PORT || 3000}`);
});