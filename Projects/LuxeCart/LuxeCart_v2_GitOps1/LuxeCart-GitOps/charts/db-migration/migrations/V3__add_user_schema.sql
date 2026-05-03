INSERT INTO users (email, password, first_name, last_name, role)
VALUES (
'popo@luxecart.com',
'NEEDS_BCRYPT_HASH',
'Popo',
'Ola',
'user'
)
ON CONFLICT (email) DO NOTHING;