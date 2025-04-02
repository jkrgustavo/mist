module InfoCards = {

    module CardContainer = {
        [@react.component]
        let make = (~children) => {
            
            <div className="flex items-center justify-center [&>div]:w-full [&>div]:h-full my-[5%] 
                w-[400px] h-[250px]"
            >
                {children}
            </div>
        };
    };

    module InfoCard = {
        [@react.component]
        let make = (~title: string, ~desc: string, ~body: string, ~className=?) => {
            open Shadcn.Cards;

            let cls = Option.value(className, ~default="");

            <Card className=cls>
                <CardHeader>
                    <CardTitle className="text-2xl">{React.string(title)}</CardTitle>
                    <CardDescription>{React.string(desc)}</CardDescription>
                </CardHeader>
                <CardContent>
                    {body |> React.string}
                </CardContent>
            </Card>
        };
    };
};

module Logo = {
    [@react.component]
    let make = () => {
        <svg xmlns="http://www.w3.org/2000/svg" width="740" height="120" viewBox="0 0 740 120">
            <defs>
                <linearGradient id="gradient" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="740" y2="0">
                    <stop offset="0%" stopColor="var(--ring)" />
                    <stop offset="100%" stopColor="var(--foreground)" />
                </linearGradient>
                <mask id="mask" maskUnits="userSpaceOnUse" x="0" y="0" width="740" height="120">
                    <rect width="740" height="120" fill="black" />
                    <use href="#M" x="0" y="10" fill="white" />
                    <use href="#O" x="110" y="10" fill="white" />
                    <use href="#R" x="220" y="10" fill="white" />
                    <use href="#R" x="330" y="10" fill="white" />
                    <use href="#A" x="440" y="10" fill="white" />
                    <use href="#A" x="550" y="10" fill="white" />
                    <use href="#D" x="660" y="10" fill="white" />
                </mask>
                <path id="M" d="M0,100 L0,0 L30,0 L50,50 L70,0 L100,0 L100,100 L70,100 L50,50 L30,100 Z" />
                <path id="O" d="M0,0 L100,0 L100,100 L0,100 Z M20,20 L20,80 L80,80 L80,20 Z" fillRule="evenodd" />
                <g id="R">
                    <path d="M0,0 L0,100 L30,100 L30,0 Z" />
                    <path d="M30,0 L60,0 L60,40 L30,40 Z" />
                    <path d="M30,40 L60,100 L90,100 L60,40 Z" />
                </g>
                <path id="A" d="M0,100 L40,0 L60,0 L100,100 Z M45,60 L55,60 L50,90 Z" fillRule="evenodd" />
                <path id="D" d="M0,0 L0,100 L60,100 L80,50 L60,0 Z M20,20 L20,80 L40,80 L40,20 Z" fillRule="evenodd" />
            </defs>
            <rect width="740" height="120" fill="url(#gradient)" mask="url(#mask)" />
        </svg>
    };
};


[@react.component]
let make = () => {
    open InfoCards;
    open Lib;
    module RRR = ReasonReactRouter;

    <div className="flex h-screen w-screen items-center justify-start flex-col">
        <div className="flex items-center space-x-4">
            <CardContainer>
                <InfoCard 
                    title="Blogs" 
                    desc="Yes I have one" 
                    body="Mostly for my sake, I need to practice writing. If I learn about 
                        something cool maybe I'll write a blog about it, if I finish
                        a project I'm proud of maybe I'll write a blog about it, if I feel like
                        writing then maybe I'll write a blog about it." 
                    className="hidden sm:block"
                />
            </CardContainer>
            <CardContainer>
                <InfoCard 
                    title="About Me" 
                    desc="Who am I??" 
                    body="This is supposed to be a short and punchy intro that keeps going on and on and on and" 
                />
            </CardContainer>
            <CardContainer>
                <InfoCard 
                    title="Projects" 
                    desc="What kind of projects I work on" 
                    body="Started out with a mind for web-dev and learned how much variety there is
                        in this field. I don't really have an end goal but I love creating and 
                        building things from the ground up." 
                    className="hidden sm:block"
                />
            </CardContainer>
        </div>
        <div className="flex flex-col items-center space-y-4"> // title
            <Logo />
            <Shadcn.Separator />
            <div className="flex items-center justify-center space-x-5 w-[80%] 
                [&>div]:flex [&>div]:items-center [&>div]:space-x-2"
            >
                <div>
                    <Shadcn.Button 
                        className="w-6 h-6" 
                        variant="ghost" 
                        size="icon" 
                        asChild=true 
                        onClick={(_) => {Js.log("Mail clicked!!")}}
                    >
                        <Lucide.Mail />
                    </Shadcn.Button>
                    <p>{React.string("Email me")}</p>
                </div>
                <Shadcn.Separator orientation="vertical" />
                <div>
                    <Shadcn.Button 
                        className="w-6 h-6" 
                        variant="ghost" 
                        size="icon" 
                        asChild=true 
                        onClick={(_) => {Js.log("Github clicked!!"); RRR.push("/article")}}
                    >
                        <Lucide.Github />
                    </Shadcn.Button>
                    <p>{React.string("Github")}</p>
                </div>
                <Shadcn.Separator orientation="vertical" />
                <div>
                    <Shadcn.Button 
                        className="w-6 h-6" 
                        variant="ghost" 
                        size="icon" 
                        asChild=true 
                        onClick={(_) => {Js.log("Blog clicked!!")}}
                    >
                        <Lucide.NotepadText />
                    </Shadcn.Button>
                    <p>{React.string("My blog")}</p>
                </div>
                
            </div>
        </div>
        <img src="/redbud.png" alt="img here" className="relative bottom-0 right-[33.5%]" /> // tree-photo
    </div>
}

// TODO: Respond to window resizing
