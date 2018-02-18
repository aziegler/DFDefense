
NAME = GentryFight

LOVE_NAME = $(NAME).love
WIN_NAME = $(NAME).win64.zip
OSX_NAME = $(NAME).macosx.zip

LOVE_WIN64_VERSION = love-0.10.2-win64
LOVE_OSX_VERSION = love-0.10.2-macosx-x64

all: $(LOVE_NAME) $(WIN_NAME) $(OSX_NAME)

love: $(LOVE_NAME)

$(LOVE_NAME) :
	git archive --format=zip --output=GentryFight.love master

$(LOVE_WIN64_VERSION).zip :
	wget https://bitbucket.org/rude/love/downloads/$(LOVE_WIN64_VERSION).zip
$(LOVE_OSX_VERSION).zip :
	wget https://bitbucket.org/rude/love/downloads/$(LOVE_OSX_VERSION).zip

$(WIN_NAME): $(LOVE_WIN64_VERSION).zip $(LOVE_NAME)
	unzip $(LOVE_WIN64_VERSION).zip
	mv $(LOVE_WIN64_VERSION) $(NAME)
	cat $(NAME)/love.exe $(LOVE_NAME) > $(NAME)/$(NAME).exe
	chmod +x $(NAME)/$(NAME).exe
	rm $(NAME)/love.exe $(NAME)/lovec.exe
	zip -r $(WIN_NAME) $(NAME)
	$(RM) -r $(NAME)

$(OSX_NAME): $(LOVE_OSX_VERSION).zip $(LOVE_NAME)
	unzip $(LOVE_OSX_VERSION).zip
	mv love.app $(NAME).app
	cp $(LOVE_NAME) $(NAME).app/Contents/Resources/
	cp assets/Info.plist $(NAME).app/Contents/
	zip -r -y $(OSX_NAME) $(NAME).app
	$(RM) -r $(NAME).app

clean:
	$(RM) -r $(NAME) $(LOVE_NAME) $(WIN_NAME) $(OSX_NAME)

fclean: clean
	$(RM) $(LOVE_WIN64_VERSION).zip $(LOVE_OSX_VERSION).zip

re: clean all
