//Sin SQLQuery
const nuevo = async ({ id, saldo }) => {
    try {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const crear = "INSERT INTO cuenta (id, saldo) VALUES ($1, $2) RETURNING *";
            const param = [id, saldo];
            const nuevaCuenta = await client.query(crear, param);
            console.log("Cuenta creada con éxito: ", nuevaCuenta.rows[0]);
            await client.query("COMMIT");
        } catch (error) {
            await client.query("ROLLBACK");
            //console.log('error :>> ', error);
            console.error('error message:', error.message);
            console.error('code:', error.code);
            console.error('detail:', error.detail);
        }
        client.release();
        pool.end();
    } catch (error) {
        console.log('error :>> ', error);
        console.error(error.message);
        console.error(error.code);
    }
};
