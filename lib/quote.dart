import 'dart:math';

class Quote {
  static Map<String, String> quotes = {
    "The way to get started is to quit talking and begin doing.": "Walt Disney",
    "Success is not final, failure is not fatal: It is the courage to continue that counts.": "Winston Churchill",
    "The future belongs to those who believe in the beauty of their dreams.": "Eleanor Roosevelt",
    "In the middle of every difficulty lies opportunity.": "Albert Einstein",
    "Believe you can and you're halfway there.": "Theodore Roosevelt",
    "The only way to do great work is to love what you do.": "Steve Jobs",
    "Do what you have to do until you can do what you want to do.": "Oprah Winfrey",
    "Whether you think you can or you think you can't, you're right.": "Henry Ford",
    "It always seems impossible until it's done.": "Nelson Mandela",
    "It does not matter how slowly you go as long as you do not stop.": "Confucius",
    "Setting goals is the first step in turning the invisible into the visible.": "Tony Robbins",
    "Perfection is not attainable, but if we chase perfection we can catch excellence.": "Vince Lombardi",
    "You're off to great places! Today is your day! Your mountain is waiting, so get on your way!": "Dr. Seuss",
    "The secret of getting ahead is getting started.": "Mark Twain",
    "You will face many defeats in life, but never let yourself be defeated.": "Maya Angelou",
    "Your attitude, not your aptitude, will determine your altitude.": "Zig Ziglar",
    "Things work out best for those who make the best of how things work out.": "John Wooden",
    "Either you run the day or the day runs you.": "Jim Rohn",
    "The best way to predict the future is to create it.": "Abraham Lincoln",
    "Keep your face to the sunshine and you cannot see a shadow.": "Helen Keller",
    "Energy and persistence conquer all things.": "Benjamin Franklin",
    "You miss 100% of the shots you don't take.": "Wayne Gretzky",
    "I've failed over and over and over again in my life, and that is why I succeed.": "Michael Jordan",
    "What lies behind us and what lies before us are tiny matters compared to what lies within us.": "Ralph Waldo Emerson",
    "Shoot for the moon. Even if you miss, you'll land among the stars.": "Les Brown",
    "Happiness is not something ready made. It comes from your own actions.": "Dalai Lama",
    "We are what we repeatedly do. Excellence, then, is not an act, but a habit.": "Aristotle",
    "It is our choices that show what we truly are, far more than our abilities.": "J.K. Rowling",
    "Every great dream begins with a dreamer.": "Harriet Tubman",
    "The successful warrior is the average man, with laser-like focus.": "Bruce Lee",
    "In the midst of chaos, there is also opportunity.": "Sun Tzu",
    "Go confidently in the direction of your dreams. Live the life you have imagined.": "Henry David Thoreau",
    "It's hard to beat a person who never gives up.": "Babe Ruth",
    "The most effective way to do it, is to do it.": "Amelia Earhart",
    "Genius is one percent inspiration and ninety-nine percent perspiration.": "Thomas Edison",
    "Tough times never last, but tough people do.": "Robert H. Schuller",
    "Change your thoughts and you change your world.": "Norman Vincent Peale",
    "Everything you can imagine is real.": "Pablo Picasso",
    "Done is better than perfect.": "Sheryl Sandberg",
    "Nothing in life is to be feared, it is only to be understood.": "Marie Curie",
    "The future rewards those who press on. I don’t have time to feel sorry for myself.": "Barack Obama",
    "What you seek is seeking you.": "Rumi",
    "You are never too old to set another goal or to dream a new dream.": "C.S. Lewis",
    "Set your goals high, and don’t stop till you get there.": "Bo Jackson",
    "The best way to predict your future is to create it.": "Peter Drucker",
    "Be uncommon amongst uncommon people.": "David Goggins",
    "A champion is defined not by their wins but by how they can recover when they fall.": "Serena Williams",
    "Let us make our future now, and let us make our dreams tomorrow's reality.": "Malala Yousafzai",
    "Each person must live their life as a model for others.": "Rosa Parks",
    "You can choose courage, or you can choose comfort, but you cannot choose both.": "Brene Brown",
    "Don't wait for perfection. Start today.": "Jon Acuff",
    "Success is your duty, obligation, and responsibility.": "Grant Cardone",
    "Waiting for perfect is never as smart as making progress.": "Seth Godin",
    "Enthusiasm is common. Endurance is rare.": "Angela Duckworth",
    "The secret to success is good leadership, and good leadership is all about making the lives of your team members better.": "Tony Dungy",
    "The key is in not spending time, but in investing it.": "Stephen Covey",
    "Make your life a masterpiece; imagine no limitations on what you can be, have, or do.": "Brian Tracy",
    "Don't worry about failures; worry about the chances you miss when you don't even try.": "Jack Canfield",
    "Don't count the days, make the days count.": "Muhammad Ali",
    "Working hard for something we don't care about is called stress; working hard for something we love is called passion.": "Simon Sinek",
    "Do not be embarrassed by your failures, learn from them and start again.": "Richard Branson",
    "I never dreamed about success. I worked for it.": "Estée Lauder",
    "Life is 10% what happens to us and 90% how we react to it.": "Charles Swindoll",
    "Say yes, and you'll figure it out afterwards.": "Tina Fey",
    "An entrepreneur is someone who jumps off a cliff and builds a plane on the way down.": "Reid Hoffman",
    "Do or do not. There is no try.": "Yoda",
    "Great things come from hard work and perseverance. No excuses.": "Kobe Bryant",
    "Do not allow people to dim your shine because they are blinded. Tell them to put some sunglasses on.": "Lady Gaga",
    "How wonderful it is that nobody need wait a single moment before starting to improve the world.": "Anne Frank",
    "Don't compare yourself with anyone in this world. If you do so, you are insulting yourself.": "Bill Gates",
    "If you double the number of experiments you do per year, you're going to double your inventiveness.": "Jeff Bezos",
    "Success is not the key to happiness. Happiness is the key to success. If you love what you are doing, you will be successful.": "Albert Schweitzer",
    "Life isn’t about finding yourself. Life is about creating yourself.": "George Bernard Shaw",
    "Don't be pushed around by the fears in your mind. Be led by the dreams in your heart.": "Roy T. Bennett",
    "Whatever the mind can conceive and believe, it can achieve.": "Napoleon Hill",
    "I am not what happened to me, I am what I choose to become.": "Carl Jung",
    "I'm a great believer in luck, and I find the harder I work the more I have of it.": "Thomas Jefferson",
    "When we are no longer able to change a situation, we are challenged to change ourselves.": "Viktor Frankl",
    "At the end of the day, it’s not about what you have or even what you’ve accomplished. It’s about who you’ve lifted up, who you’ve made better. It’s about what you’ve given back.": "Denzel Washington",
    "It is never too late to be what you might have been.": "George Eliot",
    "If there is no struggle, there is no progress.": "Frederick Douglass",
    "Everyone thinks of changing the world, but no one thinks of changing himself.": "Leo Tolstoy",
    "You do not rise to the level of your goals. You fall to the level of your systems.": "James Clear",
    "Act as if what you do makes a difference. It does.": "William James",
    "The question isn’t who is going to let me; it’s who is going to stop me.": "Ayn Rand",
    "It’s through mistakes that you actually can grow. You have to get bad in order to get good.": "J.J. Abrams",
    "I may not have gone where I intended to go, but I think I have ended up where I needed to be.": "Douglas Adams"
  };

  late String quote;
  late String author;

  Quote() {
    int rn = Random().nextInt(quotes.length);
    quote = quotes.keys.elementAt(rn);
    author = quotes[quote]!;
  }
}