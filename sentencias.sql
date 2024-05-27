const { Pool } = require("pg");
const Cursor = require("pg-cursor");
require('dotenv').config();

const config = {
    user: process.env.PG_USER,
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE,
    password: process.env.PG_PASSWORD,
    port: process.env.PG_PORT,
    max: process.env.PG_POOL_MAX,
    idleTimeoutMillis: process.env.PG_POOL_IDLE_TIMEOUT_MILLIS,
    connectionTimeoutMillis: process.env.PG_POOL_CONNECTION_TIMEOUT_MILLIS,
};

const pool = new Pool(config);

// Constantes y Process Argv para Captura de Comandos en la Terminal.
const argumentos = process.argv.slice(2);
const proceso = argumentos[0];
const descripcion = argumentos[0];
const id = argumentos[1];
const saldo = argumentos[2];
const fecha = argumentos[3];
const id2 = argumentos[4];

// Crear Nueva Cuenta
const nuevo = async ({ id, saldo }) => {
    try {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const SQLQuery = {
                text: "INSERT INTO cuenta (id, saldo) VALUES ($1, $2) RETURNING *",
                values: [id, saldo],
            };
            const res = await client.query(SQLQuery);
            console.log("Cuenta creada con éxito: ", res.rows);
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
// Crear un Deposito en Cuenta
const deposito = async ({ descripcion, id, saldo, fecha }) => {
    try {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const SQLQuery = {
                text: "INSERT INTO transaccion (descripcion, cuenta, monto, fecha) VALUES ($1, $2, $3, $4) RETURNING *",
                values: [descripcion, id, saldo, fecha],
            };
            const SQLQuery2 = {
                text: "UPDATE cuenta SET saldo = saldo + $2 WHERE id = $1 RETURNING *",
                values: [id, saldo],
            };
            const res = await client.query(SQLQuery);
            const res2 = await client.query(SQLQuery2);
            console.log("Deposito realizado con éxito: ", res.rows);
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
// Crear un Retiro en Cuenta
const retiro = async ({ descripcion, id, saldo, fecha }) => {
    try {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const SQLQuery = {
                text: "UPDATE cuenta SET saldo = saldo - $2 WHERE id = $1 RETURNING *",
                values: [id, saldo],
            };
            const SQLQuery2 = {
                text: "INSERT INTO transaccion (descripcion, cuenta, monto, fecha) VALUES ($1, $2, $3, $4) RETURNING *",
                values: [descripcion, id, saldo, fecha],
            };
            const res = await client.query(SQLQuery);
            const res2 = await client.query(SQLQuery2);
            console.log("Retiro realizado con éxito: ", res.rows);
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
// Crear una Transferencia entre Cuentas
const transferencia = async ({ descripcion, id, saldo, fecha, id2 }) => {
    try {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const SQLQuery = {
                text: "UPDATE cuenta SET saldo = saldo - $2 WHERE id = $1 RETURNING *",
                values: [id, saldo],
            };
            const SQLQuery2 = {
                text: "INSERT INTO transaccion (descripcion, cuenta, monto, fecha) VALUES ($1, $2, $3, $4) RETURNING *",
                values: [descripcion, id, saldo, fecha],
            };
            const SQLQuery3 = {
                text: "UPDATE cuenta SET saldo = saldo + $2 WHERE id = $1 RETURNING *",
                values: [id2, saldo],
            };
            const SQLQuery4 = {
                text: "INSERT INTO transaccion (descripcion, cuenta, monto, fecha) VALUES ($1, $2, $3, $4) RETURNING *",
                values: [descripcion, id2, saldo, fecha],
            };
            const res = await client.query(SQLQuery);
            const res2 = await client.query(SQLQuery2);
            const res3 = await client.query(SQLQuery3);
            const res4 = await client.query(SQLQuery4);
            console.log("Transferencia realizada, Monto Debitado con éxito: ", res.rows);
            console.log("Transferencia realizada, Monto Abonado con éxito: ", res3.rows);
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
// Consulta Transacciones Generales
const consultaTransacciones = async () => {
    try {
        const client = await pool.connect();
        try {
            const text = "SELECT id, descripcion, cuenta, monto, fecha FROM transaccion";
            const consulta = new Cursor(text);
            const cursor = await client.query(consulta);
            try {
                let rows;
                do {
                    rows = await cursor.read(10);
                    console.log(rows);
                    console.log("length: ", rows.length);
                } while (rows.length > 0);
                try {
                    await cursor.close();
                } catch (error) {
                    console.log('error :>> ', error);
                }
            } catch (error) {
                console.log('error :>> ', error);
            }
        } catch (error) {
            console.log('error :>> ', error);
            console.error(error.message);
            console.error(error.code);
        }
        client.release();
        pool.end();
    } catch (error) {
        console.log('error :>> ', error);
        console.error(error.message);
        console.error(error.code);
    }
};
// Consulta Transacciones por ID
const consultaTransaccionesporid = async ({ id }) => {
    try {
        const client = await pool.connect();
        try {
            const text = "SELECT id, descripcion, cuenta, monto, fecha FROM transaccion WHERE cuenta = $1";
            const values = [id];
            const consulta = new Cursor(text, values);
            const cursor = await client.query(consulta);
            try {
                let rows;
                do {
                    rows = await cursor.read(10);
                    console.log(rows);
                    console.log("length: ", rows.length);
                } while (rows.length > 0);
                try {
                    await cursor.close();
                } catch (error) {
                    console.log('error :>> ', error);
                }
            } catch (error) {
                console.log('error :>> ', error);
            }
        } catch (error) {
            console.log('error :>> ', error);
            console.error(error.message);
            console.error(error.code);
        }
        client.release();
        pool.end();
    } catch (error) {
        console.log('error :>> ', error);
        console.error(error.message);
        console.error(error.code);
    }
};
// Consulta Saldo de una Cuenta por ID
const consultaSaldoporid = async ({ id }) => {
    try {
        const client = await pool.connect();
        try {
            const text = "SELECT id, saldo FROM cuenta WHERE id = $1";
            const values = [id];
            const consulta = new Cursor(text, values);
            const cursor = await client.query(consulta);
            try {
                let rows;
                rows = await cursor.read(10);
                console.log(rows);
                try {
                    await cursor.close();
                } catch (error) {
                    console.log('error :>> ', error);
                }
            } catch (error) {
                console.log('error :>> ', error);
            }
        } catch (error) {
            console.log('error :>> ', error);
            console.error(error.message);
            console.error(error.code);
        }
        client.release();
        pool.end();
    } catch (error) {
        console.log('error :>> ', error);
        console.error(error.message);
        console.error(error.code);
    }
};

// Nuevo, Deposito, Retiro y Transferencias de Cuentas.
const main = async () => {
    const est = {
        id, saldo
    }
    const est1 = {
        descripcion, id, saldo, fecha
    }
    const est3 = {
        id
    }
    const est4 = {
        descripcion, id, saldo, fecha, id2
    }
    if (proceso == 'nuevo') {
        await nuevo(est);
    }
    else if (proceso == 'deposito') {
        await deposito(est1);
    }
    else if (proceso == 'retiro') {
        await retiro(est1);
    }
    else if (proceso == 'transferencia') {
        await transferencia(est4);
    }
    else if (proceso == 'transacciones') {
        consultaTransacciones();
    }
    else if (proceso == 'transaccion') {
        await consultaTransaccionesporid(est3);
    }
    else if (proceso == 'consulta') {
        await consultaSaldoporid(est3);
    }
    else {
        console.log("no existe");
    };
};

main();