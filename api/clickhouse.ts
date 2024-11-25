import { createClient } from '@clickhouse/client';

const client = createClient({
  host: 'https://crypto-clickhouse.clickhouse.com',
  username: 'crypto',
  password: '',
  database: 'default', 
});

export const queryClickHouse = async (query: string) => {
    console.log('query:', query);
    try {
      const rows = await client.query({
      query,
      format: 'JSONEachRow',
    });
    console.log('rows:', rows);

    const data = [];
    for await (const row of rows.stream()) {
      data.push(row);
    }

        return data;
  } catch (error) {
    console.error('Error querying ClickHouse:', error);
  }
};
