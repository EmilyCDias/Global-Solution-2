

CREATE DATABASE GestaoEnergia;
USE GestaoEnergia;

-- CRIAÇÃO TABELAS

-- Usuario
CREATE TABLE Usuario (
    idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    senha VARCHAR(50) NOT NULL
);

-- Endereco
CREATE TABLE Endereco (
    idEndereco INT AUTO_INCREMENT PRIMARY KEY,
    logradouro VARCHAR(255) NOT NULL,
    numero INT NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    cep VARCHAR(8) NOT NULL,
    idUsuario INT NOT NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

-- Consumo
CREATE TABLE Consumo (
    idConsumo INT AUTO_INCREMENT PRIMARY KEY,
    menorConsumo DOUBLE NOT NULL,
    maiorConsumo DOUBLE NOT NULL,
    totalConsumo DOUBLE NOT NULL,
    dataInicial DATE NOT NULL,
    dataFinal DATE NOT NULL,
    idUsuario INT NOT NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

-- ItemConsumo
CREATE TABLE ItemConsumo (
    idItemConsumo INT AUTO_INCREMENT PRIMARY KEY,
    mes DATE NOT NULL,
    consumoUnidade DOUBLE NOT NULL,
    valorFatura DOUBLE NOT NULL,
    pago BOOLEAN DEFAULT FALSE,
    idConsumo INT NOT NULL,
    FOREIGN KEY (idConsumo) REFERENCES Consumo(idConsumo)
);

-- ProvedorEnergia
CREATE TABLE ProvedorEnergia (
    idProvedor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL
);

-- HorarioPico
CREATE TABLE HorarioPico (
    idHorarioPico INT AUTO_INCREMENT PRIMARY KEY,
    horaInicio TIME NOT NULL,
    horaFim TIME NOT NULL,
    idProvedor INT NOT NULL,
    FOREIGN KEY (idProvedor) REFERENCES ProvedorEnergia(idProvedor)
);

-- Tarifa
CREATE TABLE Tarifa (
    idTarifa INT AUTO_INCREMENT PRIMARY KEY,
    data DATE NOT NULL,
    idProvedor INT NOT NULL,
    FOREIGN KEY (idProvedor) REFERENCES ProvedorEnergia(idProvedor)
);

-- TarifaItem
CREATE TABLE TarifaItem (
    idTarifaItem INT AUTO_INCREMENT PRIMARY KEY,
    hora TIME NOT NULL,
    preco DOUBLE NOT NULL,
    idTarifa INT NOT NULL,
    FOREIGN KEY (idTarifa) REFERENCES Tarifa(idTarifa)
);


-- Inserção de Dados Iniciais


-- Dados da tabela Usuario
INSERT INTO Usuario (nome, cpf, senha) VALUES 
('João Silva', '12345678901', 'senha123'),
('Maria Oliveira', '98765432100', 'senha456');

-- Dados da tabela Endereco
INSERT INTO Endereco (logradouro, numero, cidade, estado, cep, idUsuario) VALUES 
('Rua A', 123, 'São Paulo', 'SP', '01001000', 1),
('Avenida B', 456, 'Rio de Janeiro', 'RJ', '22020001', 2);

-- Dados da tabela ProvedorEnergia
INSERT INTO ProvedorEnergia (nome, estado) VALUES 
('Energisa', 'SP'),
('Light', 'RJ');

-- Dados da tabela Consumo
INSERT INTO Consumo (menorConsumo, maiorConsumo, totalConsumo, dataInicial, dataFinal, idUsuario) VALUES 
(10.5, 50.0, 200.0, '2024-01-01', '2024-01-31', 1),
(5.0, 30.0, 100.0, '2024-02-01', '2024-02-28', 2);

-- Dados da tabela ItemConsumo
INSERT INTO ItemConsumo (mes, consumoUnidade, valorFatura, pago, idConsumo) VALUES 
('2024-01-15', 20.0, 150.0, TRUE, 1),
('2024-02-20', 10.0, 80.0, FALSE, 2);

-- Dados da tabela HorarioPico
INSERT INTO HorarioPico (horaInicio, horaFim, idProvedor) VALUES 
('18:00:00', '21:00:00', 1),
('17:00:00', '20:00:00', 2);

-- Dados da tabela Tarifa
INSERT INTO Tarifa (data, idProvedor) VALUES 
('2024-01-01', 1),
('2024-02-01', 2);

-- Dados da tabela TarifaItem
INSERT INTO TarifaItem (hora, preco, idTarifa) VALUES 
('10:00:00', 0.5, 1),
('20:00:00', 0.8, 2);


-- Atualização de dados
UPDATE Usuario
SET senha = SHA2(senha, 256)
WHERE LENGTH(senha) < 64; 


-- Exclusão de dados
DELETE FROM ItemConsumo WHERE idItemConsumo = 2;



--  Consulta de Empresas Disponíveis por Estado
CREATE PROCEDURE ConsultaEmpresasDisponiveisPorEstado(IN estadoInput VARCHAR(255))
BEGIN
    SELECT DISTINCT p.nome AS Empresa
    FROM Endereco e
    JOIN ProvedorEnergia p ON e.estado = p.estado
    WHERE e.estado = estadoInput;
END;

--  Consulta de Preços por Hora para um Provedor
-- Retorna o valor do Watt por hora de acordo com o provedor selecionado
CREATE PROCEDURE ConsultaPrecosPorHora(IN nomeProvedor VARCHAR(255))
BEGIN
    SELECT ti.hora AS Hora, ti.preco AS Preco
    FROM TarifaItem ti
    JOIN Tarifa t ON ti.idTarifa = t.idTarifa
    JOIN ProvedorEnergia p ON t.idProvedor = p.idProvedor
    WHERE p.nome = nomeProvedor;
END;

--  Detalhes de Consumo de Energia de um Cliente
-- Retorna os dados de consumo de um cliente com base no CPF e senha fornecidos
CREATE PROCEDURE DetalhesConsumoCliente(IN cpfInput VARCHAR(11), IN senhaInput VARCHAR(255))
BEGIN
    SELECT c.menorConsumo AS Menor_Consumo,
           c.maiorConsumo AS Maior_Consumo,
           c.totalConsumo AS Total_Consumo,
           ic.mes AS Mes,
           ic.consumoUnidade AS Consumo_Unidade
    FROM Usuario u
    JOIN Consumo c ON u.idUsuario = c.idUsuario
    JOIN ItemConsumo ic ON c.idConsumo = ic.idConsumo
    WHERE u.cpf = cpfInput AND u.senha = senhaInput;
END;
