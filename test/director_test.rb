require File.dirname(__FILE__) + '/test_helper'

context "Director proxy generation" do

  def setup
    if !defined?(@@director_built)
      super
      @@director_built = true 
      Extension.new "director" do |e|
        e.sources full_dir("headers/director.h")

        node = e.namespace "director"
        node.classes("Worker").methods("doProcessImpl").default_return_value(0)

        klass = node.classes("BadNameClass")
        klass.wrap_as("BetterNamedClass")
        klass.methods("_is_x_ok_to_run").wrap_as("x_ok?")
        klass.methods("__do_someProcessing").wrap_as("do_processing")
      end

      require 'director'
    end
  end

  specify "polymorphic calls extend into Ruby" do
    class MyWorker < Worker
      def process(num)
        num + 10
      end
    end

    h = Handler.new
    h.add_worker(MyWorker.new)

    h.process_workers(5).should.equal 15
  end

  specify "super calls on pure virtual raise exception" do
    class SuperBadWorker < Worker
      def process(num)
        super + 10
      end
    end

    should.raise NotImplementedError do
      SuperBadWorker.new.process(10)
    end
  end

  specify "allows super calls to continue back into C++ classes" do
    class SuperGoodWorker < Worker
      def do_something(num)
        super + 10
      end
    end

    should.not.raise NotImplementedError do
      SuperGoodWorker.new.do_something(10).should.equal 50
    end
  end

  specify "can specify a default return value in the wrapper" do
    class MyAwesomeWorker < Worker
      def do_process_impl(num)
        num + 7
      end

      def process(num)
        num + 8
      end
    end    

    w = MyAwesomeWorker.new
    w.do_process(3).should.equal 10

    h = Handler.new
    h.add_worker(w)

    h.process_workers(10).should.equal 18
  end

  specify "properly adds all constructor arguments" do
    v = VirtualWithArgs.new 14, true
    v.process_a.should.equal 14
    v.process_b.should.be true
  end

  specify "takes into account renamed methods / classes" do
    c = BetterNamedClass.new
    assert !c.x_ok?

    c.do_processing.should.equal 14
  end

  specify "handles no constructors" do
    class MyThing < NoConstructor
    end

    n = MyThing.new
    n.do_something.should.equal 4
  end

  # TODO Is this a valid / common use case?
  xspecify "handles superclasses of the class with virtual methods" do
    class QuadWorker < MultiplyWorker
      def process(num)
        num * 4
      end
    end

    h = Handler.new

    h.add_worker(MultiplyWorker.new)
    h.process_workers(5).should.equal 10

    h.add_worker(QuadWorker.new)
    h.process_workers(5).should.equal 40
  end

end