import express from 'express';
import getRawBody from 'raw-body';

const app = express();

// Raw request logging before any parsing
app.use(async (req, res, next) => {
  const timestamp = new Date().toISOString();
  
  console.log(`[${timestamp}] Raw Request:`, {
    method: req.method,
    url: req.url,
    headers: req.headers,
  });

  try {
    const rawBody = await getRawBody(req, {
      length: req.headers['content-length'],
      limit: '1mb',
      encoding: true
    });
    console.log(`[${timestamp}] Raw body:`, rawBody);
    req.body = rawBody;
  } catch (e) {
    console.error('Error reading raw body:', e);
  }
  
  next();
});

// JSON parsing middleware with error handling
app.use((req, res, next) => {
  express.json()(req, res, (err) => {
    if (err) {
      console.error('JSON parsing error:', err);
      return res.status(400).json({
        error: 'Invalid JSON',
        details: err.message
      });
    }
    next();
  });
});

// Root handler that accepts anything
app.post('/', (req, res) => {
  console.log('Webhook received:', {
    contentType: req.headers['content-type'],
    body: req.body,
    headers: req.headers
  });
  
  res.status(200).json({ received: true });
});

app.listen(process.env.PORT || 3000, () => {
  console.log(`Server running on port ${process.env.PORT || 3000}`);
});