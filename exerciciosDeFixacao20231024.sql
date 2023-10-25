CREATE DATABASE exercicios_trigger;
USE exercicios_trigger;

-- Criação das tabelas
CREATE TABLE Clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE Auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mensagem TEXT NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    estoque INT NOT NULL
);

CREATE TABLE Pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT,
    quantidade INT NOT NULL,
    FOREIGN KEY (produto_id) REFERENCES Produtos(id)
);

/*Ex 1*/

CREATE TRIGGER ColocarCliente
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Um novo cliente foi colocado em ', NOW()));
END;

/*Ex 2*/

CREATE TRIGGER ExclusaoCliente
BEFORE DELETE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES ('Tentativa de exclusão de cliente');
END;

/*Ex 3*/

CREATE TRIGGER AtualizaNome
BEFORE UPDATE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Nome antigo: ', OLD.nome, ', Novo nome: ', NEW.nome));
END;

/*Ex 4*/

DELIMITER //
CREATE TRIGGER NaoPermVazio
BEFORE UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.nome IS NULL OR NEW.nome = '' THEN
        INSERT INTO Auditoria (mensagem) VALUES ('Tentativa de atualizar o nome do cliente para vazio ou NULL');
        SET message_texto = 'Não é permitido atualizar o nome do cliente para vazio ou NULL.';
    END IF;
END;
//
DELIMITER ;


/*Ex 5*/

CREATE TRIGGER AtualizaPedidos
AFTER INSERT ON Pedidos
FOR EACH ROW
BEGIN

    UPDATE Produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id;
    
    DECLARE @estoque_atual INT;
    SET @estoque_atual = (SELECT estoque FROM Produtos WHERE id = NEW.produto_id);
    
    IF @estoque_atual < 5 THEN
        INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Estoque baixo para o produto ', NEW.produto_id, '. Estoque atual: '));
    END IF;
END;
