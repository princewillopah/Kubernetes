INSERT INTO users (email, password, first_name, last_name, role)
VALUES (
'marketing@luxecart.com',
'NEEDS_BCRYPT_HASH',
'Marketing',
'Manager',
'user'
)
ON CONFLICT (email) DO NOTHING;