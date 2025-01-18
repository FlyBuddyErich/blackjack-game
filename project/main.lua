-- Константы
CARD_WIDTH = 60
CARD_HEIGHT = 80
SCALE = 0.3

function love.load()
    -- Загрузка шрифта с поддержкой кириллицы
    font = love.graphics.newFont("arial.ttf", 24) -- Укажите путь к файлу шрифта
    love.graphics.setFont(font)

    -- Загрузка изображений карт
    cardBack = love.graphics.newImage("card_back.png")
    cardImages = {}
    for _, suit in ipairs({"hearts", "diamonds", "clubs", "spades"}) do
        for _, rank in ipairs({"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}) do
            local cardName = rank .. "_of_" .. suit
            cardImages[cardName] = love.graphics.newImage("cards/" .. cardName .. ".png")
        end
    end

    -- Инициализация колоды и рук
    initializeGame()
end

-- Инициализация колоды и рук
function initializeGame()
    suits = {"hearts", "diamonds", "clubs", "spades"}
    ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}
    deck = {}

    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            table.insert(deck, {suit = suit, rank = rank})
        end
    end

    -- Перемешивание колоды
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end

    -- Инициализация рук
    playerHand = {}
    computerHand = {}

    -- Раздача начальных карт
    table.insert(playerHand, table.remove(deck))
    table.insert(computerHand, table.remove(deck))
    table.insert(playerHand, table.remove(deck))
    table.insert(computerHand, table.remove(deck))

    -- Состояние игры
    gameState = "playerTurn"
    message = "Ваш ход. Нажмите H для взятия карты или S для остановки."
end

-- Отрисовка игры
function love.draw()
    -- Установка шрифта
    love.graphics.setFont(font)

    -- Отрисовка карт игрока
    love.graphics.print("Ваши карты:", 10, 10)
    for i, card in ipairs(playerHand) do
        local cardName = card.rank .. "_of_" .. card.suit
        love.graphics.draw(cardImages[cardName], 10 + (i - 1) * (CARD_WIDTH * SCALE), 50, 0, SCALE, SCALE)
    end

    -- Отрисовка счёта игрока
    love.graphics.print("Счёт: " .. calculateHandValue(playerHand), 10, 50 + (CARD_HEIGHT * SCALE) + 10)

    -- Отрисовка карт компьютера
    love.graphics.print("Карты компьютера:", 10, 200)
    for i, card in ipairs(computerHand) do
        if gameState == "gameOver" or i > 1 then
            local cardName = card.rank .. "_of_" .. card.suit
            love.graphics.draw(cardImages[cardName], 10 + (i - 1) * (CARD_WIDTH * SCALE), 240, 0, SCALE, SCALE)
        else
            love.graphics.draw(cardBack, 10 + (i - 1) * (CARD_WIDTH * SCALE), 240, 0, SCALE, SCALE)
        end
    end

    -- Отрисовка счёта компьютера
    if gameState == "gameOver" then
        love.graphics.print("Счёт компьютера: " .. calculateHandValue(computerHand), 10, 240 + (CARD_HEIGHT * SCALE) + 10)
    end

    -- Отрисовка сообщения
    love.graphics.print(message, 10, 400)
end

-- Обработка нажатий клавиш
function love.keypressed(key)
    if gameState == "playerTurn" then
        if key == "h" then
            table.insert(playerHand, table.remove(deck))
            if calculateHandValue(playerHand) > 21 then
                gameState = "gameOver"
                message = "Перебор! Вы проиграли."
            end
        elseif key == "s" then
            gameState = "computerTurn"
            message = "Ход компьютера."
            computerTurn()
        end
    end

    -- Рестарт игры по нажатию E
    if key == "e" then
        initializeGame()
    end
end

-- Логика хода компьютера
function computerTurn()
    while calculateHandValue(computerHand) < 17 do
        table.insert(computerHand, table.remove(deck))
    end

    if calculateHandValue(computerHand) > 21 then
        gameState = "gameOver"
        message = "Компьютер перебрал! Вы выиграли."
    else
        gameState = "gameOver"
        if calculateHandValue(playerHand) > calculateHandValue(computerHand) then
            message = "Вы выиграли!"
        elseif calculateHandValue(playerHand) < calculateHandValue(computerHand) then
            message = "Вы проиграли."
        else
            message = "Ничья!"
        end
    end
end

-- Расчет стоимости карт в руке
function calculateHandValue(hand)
    local value = 0
    local aces = 0

    for _, card in ipairs(hand) do
        if card.rank == "J" or card.rank == "Q" or card.rank == "K" then
            value = value + 10
        elseif card.rank == "A" then
            value = value + 11
            aces = aces + 1
        else
            value = value + tonumber(card.rank)
        end
    end

    -- Учитываем тузы как 1, если сумма больше 21
    while value > 21 and aces > 0 do
        value = value - 10
        aces = aces - 1
    end

    return value
end