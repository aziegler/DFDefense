
NAME = GentryFight
LOVE_NAME = $(NAME).love
ZIP_NAME = $(NAME).zip

LOVE_VERSION = love-0.10.2-win64

all: $(LOVE_NAME) $(ZIP_NAME)

love: $(LOVE_NAME)

$(LOVE_NAME) :
			git archive --format=zip --output=GentryFight.love master

$(LOVE_VERSION).zip :
			wget https://bitbucket.org/rude/love/downloads/$(LOVE_VERSION).zip

$(ZIP_NAME): $(LOVE_VERSION).zip $(LOVE_NAME)
			unzip $(LOVE_VERSION).zip
			mv $(LOVE_VERSION) $(NAME)
			cat $(NAME)/love.exe $(LOVE_NAME) > $(NAME)/$(NAME).exe
			chmod +x $(NAME)/$(NAME).exe
			rm $(NAME)/love.exe $(NAME)/lovec.exe
			zip -r $(ZIP_NAME) $(NAME)
			$(RM) -r $(NAME)

clean:
		$(RM) -r $(NAME) $(ZIP_NAME) $(LOVE_NAME) $(LOVE_VERSION).zip
