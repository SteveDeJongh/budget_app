CREATE TABLE expenses(
  id serial PRIMARY KEY,
  amount numeric(6,2) NOT NULL,
  payee text NOT NULL,
  created_on date NOT NULL,
  category text NOT NULL
);

--! Sample Data
INSERT INTO expenses (amount, payee, created_on, category)
VALUES (10, 'Superstore', '2022-01-01', 'groceries'),
       (15, 'Save on', '2022-02-02', 'groceries'),
       (20, 'bclc', '2022-01-01', 'booze'),
       (10, 'beere', '2022-02-02', 'booze'),
       (10, 'beere', '2022-03-03', 'booze'),
       (10, 'beere', '2022-01-01', 'booze'),
       (15, 'gokarting', '2022-01-01', 'entertainement'),
       (20, 'soccer', '2022-02-02', 'entertainement');