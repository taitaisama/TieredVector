
import core.stdc.string;
import std.stdio;
import std.conv;
auto r = Random(64985);
struct FixedQueue (T, size_t s){
  T [s] queue;
  size_t size = 0;
  size_t head = 0;
  alias length = size;
  enum size_t capacity = s;
  void clear () {
    size = 0;
    head = 0;
  }
  this (size_t queueSize){
    size = queueSize;
  }
  string print (){
    string str = "";
    for (int i = 0; i < s; i ++){
      if (i == size) str ~= "|";
      str ~= to!string(queue[(i+head)%s]) ~ " ";
    }
    return str;
  }
  void pushBack (T push){
    assert (size < s);
    queue[(head + size) % s] = push;
    size ++;
  }
  void pushFront (T push){
    assert (size < s);
    head = head == 0 ? s - 1 : head - 1;
    queue[head] = push;
    size ++;
  }
  void pushBack (T [] arr){
    assert (arr.length + size <= s);
    if ((head+size+arr.length)%s < (head+size)%s){
      memcpy(queue.ptr+(head+size), arr.ptr, (s-head-size)*T.sizeof);
      memcpy(queue.ptr, arr.ptr+(s-head-size), (arr.length-s+head+size)*T.sizeof);
    }
    else {
      memcpy(queue.ptr+((head+size)%s), arr.ptr, (arr.length)*T.sizeof);
    }
    size += arr.length;
  }
  void pushBack (T [] arr, ref size_t idx){
    if (arr.length - idx <= s - size){
      pushBack(arr[idx .. $]);
      idx = arr.length;
    }
    else {
      idx += s - size;
      pushBack(arr[idx-s+size .. idx]);
    }
  }
  void pushFront (T [] arr){
    assert (arr.length + size <= s);
    if (head <= arr.length){
      memcpy(queue.ptr+(s+head-arr.length), arr.ptr, (arr.length-head)*T.sizeof);
      memcpy(queue.ptr, arr.ptr+(arr.length-head), (head)*T.sizeof);
      head = (s+head-arr.length);
    }
    else {
      memcpy(queue.ptr+(head-arr.length), arr.ptr, (arr.length)*T.sizeof);
      head = (head-arr.length);
    }
    size += arr.length;
  }
  void pushFront (T [] arr, ref size_t idx){ // start front $
    if (idx <= s - size){
      pushFront(arr[0 .. idx]);
      idx = 0;
    }
    else {
      idx -= s - size;
      pushFront(arr[idx .. idx+s-size]);
    }
  }
  void popBack (size_t count){
    assert(size >= count);
    size -= count;
  }
  void popFront (size_t count){
    assert(size >= count);
    size -= count;
    head = (s+head+count)%s;
  }
  void insert (T [] arr, size_t idx){
    assert(arr.length + size <= s && idx < size);
    if (idx >= size/2){
      if ((head + size) % s > (head + size + arr.length) % s){//change
	if ((head + idx) % s > (head + idx + arr.length) % s){//change
	  memmove(queue.ptr+(head+idx+arr.length-s), queue.ptr+(head+idx), (size-idx)*T.sizeof);
	  memcpy(queue.ptr+(head+idx), arr.ptr, (s-head-idx)*T.sizeof);
	  memcpy(queue.ptr, arr.ptr+(s-head-idx), (arr.length-s+head+idx)*T.sizeof);
	}
	else {
	  memmove(queue.ptr, queue.ptr+(s-arr.length), (head+size+arr.length-s)*T.sizeof);
	  memmove(queue.ptr+(head+idx+arr.length), queue.ptr+(head+idx), (s-head-idx-arr.length)*T.sizeof);
	  memcpy(queue.ptr+(head+idx), arr.ptr, (arr.length)*T.sizeof);
	}
      }
      else {
	if ((head+idx)%s > (head+size)%s){//change
	  memmove(queue.ptr+arr.length, queue.ptr, (head+size-s)*T.sizeof);
	  if (s-head-idx < arr.length){
	    memmove(queue.ptr+(arr.length-s+head+idx), queue.ptr+(head+idx), (s-idx-head)*T.sizeof);
	    memcpy(queue.ptr+(head+idx), arr.ptr, (s-idx-head)*T.sizeof);
	    memcpy(queue.ptr, arr.ptr+(s-idx-head), (arr.length+idx+head-s)*T.sizeof);
	  }
	  else {
	    memmove(queue.ptr, queue.ptr+(s-arr.length), (arr.length)*T.sizeof);
	    memmove(queue.ptr+(head+idx+arr.length), queue.ptr+(head+idx), (s-arr.length-head-idx)*T.sizeof);
	    memcpy(queue.ptr+(head+idx), arr.ptr, (arr.length)*T.sizeof);
	  }
	}
	else {
	  memmove(queue.ptr+((head+idx+arr.length)%s), queue.ptr+((head+idx)%s), (size-idx)*T.sizeof);
	  memcpy(queue.ptr+((head+idx)%s), arr.ptr, (arr.length)*T.sizeof);
	}
      }
      size += arr.length;
    }
    else {
      if ((s+head-arr.length)%s > head){//change
	if ((s+head+idx-arr.length)%s > (head+idx)%s){//change
	  memmove(queue.ptr+(head+s-arr.length), queue.ptr+(head), (idx)*T.sizeof);
	  memcpy(queue.ptr+(head+s-arr.length+idx), arr.ptr, (arr.length-head-idx)*T.sizeof);
	  memcpy(queue.ptr, arr.ptr+(arr.length-head-idx), (head+idx)*T.sizeof);
	}
	else {
	  memmove(queue.ptr+(head+s-arr.length), queue.ptr+(head), (arr.length-head)*T.sizeof);
	  memmove(queue.ptr, queue.ptr+(arr.length), (head+idx-arr.length)*T.sizeof);
	  memcpy(queue.ptr+(head+idx-arr.length), arr.ptr, (arr.length)*T.sizeof);
	}
      }
      else {
	if ((head+idx)%s < head){
	  memmove(queue.ptr+(head-arr.length), queue.ptr+(head), (s-head)*T.sizeof);
	  if (head+idx-s < arr.length){
	    memmove(queue.ptr+(s-arr.length), queue.ptr, (head+idx-s)*T.sizeof);
	    memcpy(queue.ptr+(head+idx-arr.length), arr.ptr, (s-head-idx+arr.length)*T.sizeof);
	    memcpy(queue.ptr, arr.ptr+(s-head-idx+arr.length), (head+idx-s)*T.sizeof);
	  }
	  else {
	    memmove(queue.ptr+(s-arr.length), queue.ptr, (arr.length)*T.sizeof);
	    memmove(queue.ptr, queue.ptr+(arr.length), (head+idx-s-arr.length)*T.sizeof);
	    memcpy(queue.ptr+(head+idx-s-arr.length), arr.ptr, (arr.length)*T.sizeof);
	  }
	}
	else {
	  memmove(queue.ptr+(head-arr.length), queue.ptr+(head), (idx)*T.sizeof);
	  memcpy(queue.ptr+(head-arr.length+idx), arr.ptr, (arr.length)*T.sizeof);
	}
      }
      size += arr.length;
      head = (s+head-arr.length)%s;
    }
  }
  void remove (size_t count, size_t idx){
    assert(count+idx <= size);
    if (idx < size - (count + idx)){
      if (head+idx >= s){
    	memmove(queue.ptr+count, queue.ptr, (head+idx-s)*T.sizeof);
    	if (s - head > count){
    	  memmove(queue.ptr, queue.ptr+(s-count), (count)*T.sizeof);
    	  memmove(queue.ptr+(head+count), queue.ptr+head, (s-head-count)*T.sizeof);
    	}
    	else {
    	  memmove(queue.ptr+(count+head-s), queue.ptr+head, (s-head)*T.sizeof);
    	}
      }
      else {
    	if (head+idx+count >= s){
    	  if (head+count >= s){
    	    memmove(queue.ptr+(head+count-s), queue.ptr+(head), (idx)*T.sizeof);
    	  }
    	  else {
    	    memmove(queue.ptr, queue.ptr+(s-count), (head+idx+count-s)*T.sizeof);
    	    memmove(queue.ptr+(head+count), queue.ptr+(head), (s-head-count)*T.sizeof);
    	  }
    	}
    	else {
    	  memmove(queue.ptr+(head+count), queue.ptr+(head), (idx)*T.sizeof);
    	}
      }
      size = size - count;
      head = (head+count)%s;
    }
    else {
      if ((head+idx)%s > (head+size)%s){
	if (head+idx+count >= s){
	  if (size-count > s-head){
	    memmove(queue.ptr+(head+idx), queue.ptr+(head+idx+count-s), (s-head-idx)*T.sizeof);
	    memmove(queue.ptr, queue.ptr+(count), (head+size-s-count)*T.sizeof);
	  }
	  else {
	    memmove(queue.ptr+(head+idx), queue.ptr+(head+idx+count-s), (size-idx-count)*T.sizeof);
	  }
	}
	else {
	  memmove(queue.ptr+(head+idx), queue.ptr+(head+idx+count), (s-head-idx-count)*T.sizeof);
	  if (head+size-s > count){
	    memmove(queue.ptr+(s-count), queue.ptr, (count)*T.sizeof);
	    memmove(queue.ptr, queue.ptr+(count), (head+size-s-count)*T.sizeof);
	  }
	  else {
	    memmove(queue.ptr+(s-count), queue.ptr, (head+size-s)*T.sizeof);
	  }
	}
      }
      else {
	memmove(queue.ptr+((head+idx)%s), queue.ptr+((head+idx+count)%s), (size-idx-count)*T.sizeof);
      }
      size = size - count;
    }
  }
  void popPushRight (L) (ref L other){
    assert(size + other.size <= other.capacity);
    if (size + head > s){
      other.pushFront(queue[0 .. (head+size-s)]);
      other.pushFront(queue[head .. s]);
    }
    else {
      other.pushFront(queue[head .. head+size]);
    }
    clear();
  }
  void popPushLeft (L) (ref L other){
    assert(size + other.size <= other.capacity);
    if (size + head > s){
      other.pushBack(queue[head .. s]);
      other.pushBack(queue[0 .. (head+size-s)]);
    }
    else {
      other.pushBack(queue[head .. head+size]);
    }
    clear();
  }
  void popPushRight (L) (size_t count, ref L other){
    assert(count <= size && count + other.size <= other.capacity);
    if (count == size) {
      popPushRight(other);
      return;
    }
    if ((head+size-count)%s > (head+size)%s){
      other.pushFront(queue[0 .. (head+size-s)]);
      other.pushFront(queue[head+size-count .. s]);
    }
    else {
      other.pushFront(queue[(head+size-count)%s .. (head+size)%s]);
    }
    size -= count;
  }
  void popPushLeft (L) (size_t count, ref L other){
    assert(count <= size && count + other.size <= other.capacity);
    if (count == size) {
      popPushLeft(other);
      return;
    }
    if (count + head > s){
      other.pushBack(queue[head .. s]);
      other.pushBack(queue[0 .. (head+count-s)]);
      head += count - s;
    }
    else {
      other.pushBack(queue[head .. head+count]);
      head += count;
    }
    size -= count;
  }
  ref T opIndex (size_t idx){
    assert (idx < size);
    return queue[(head + idx) % s];
  }
  ref T indexOUtOfBounds (size_t idx){
    return queue[(head + idx) % s];
  }
  ref T absoluteIdx (size_t idx){
    return queue[idx];
  }
  size_t opDollar(){
    return size;
  }
}

size_t calcCapacity (N...)(N V){
  size_t prod = 1;
  foreach (elem; V){
    prod *= elem;
  }
  return prod;
}

struct TieredVector (T, N...) {
  enum size_t width = N[0];
  enum size_t capacity = calcCapacity(N);
  enum size_t childCapacity = capacity/width;

  static if (N.length > 2) {
    alias childType = TieredVector!(T, N[1 .. $]);
  }
  else { // N.length == 2
    alias childType = FixedQueue!(T, N[1]);
  }
  FixedQueue !(childType, width+1) queue = FixedQueue !(childType, width+1)(1);
  size_t size = 0;
  string print (){
    string s = "";
    for (int i = 0; i < width + 1; i ++){
      s ~= queue.absoluteIdx(i).print();
      if (i == queue.length){
	s ~= "|";
      }
      s ~= "\n";
    }
    return s;
  }
  ref T opIndex (size_t idx){
    assert(idx < size);
    size_t i = (idx + childCapacity - queue[0].size)/ childCapacity;
    size_t j = idx;
    if (i != 0) j += childCapacity - i*childCapacity - queue[0].size;
    return queue[i][j];
  }
  void clear (){
    for (size_t i = 0; i < queue.size; i ++){
      queue[i].clear();
    }
    queue.clear();
    size = 0;
  }
  void popBack (size_t count) {
    assert(count <= size);
    size -= count;
    while (count > queue[$-1].size){
      count -= queue[$-1].size;
      queue[$-1].clear();
      queue.size --;
    }
    queue[$-1].popBack(count);
  }
  void popFront (size_t count) {
    assert(count <= size);
    size -= count;
    while (count > queue[0].size){
      count -= queue[0].size;
      queue[0].clear();
      queue.size --;
      queue.head = queue.head == width ? 0 : queue.head + 1;
    }
    queue[0].popFront(count);
  }
  void pushBack (T [] arr){
    assert(arr.length + size <= capacity);
    size_t idx = 0;
    queue[$-1].pushBack(arr, idx);
    while (idx < arr.length){
      queue.size ++;
      queue[$-1].pushBack(arr, idx);
    }
    size += arr.length;
  }
  void pushBack (T [] arr, ref size_t idx){
    if (arr.length - idx <= capacity - size){
      pushBack(arr[idx .. $]);
      idx = arr.length;
    }
    else {
      pushBack(arr[idx .. (idx+capacity-size)]);
      idx += capacity - size;
    }
  }
  void pushFront (T [] arr){
    assert(arr.length + size <= capacity);
    size_t idx = arr.length;
    queue[0].pushFront(arr, idx);
    while (idx > 0){
      queue.size ++;
      queue.head = queue.head == 0 ? width : queue.head - 1;
      queue[0].pushFront(arr, idx);
    }
    size += arr.length;
  }
  void pushFront (T [] arr, ref size_t idx){
    if (idx <= capacity - size){
      pushFront(arr[0 .. idx]);
      idx = arr.length;
    }
    else {
      pushFront(arr[(idx-capacity+size) .. idx]);
      idx -= capacity - size;
    }
  }
  void popPushRight (L)(ref L other){
    assert(other.size + size <= other.capacity);
    for (int i = queue.size - 1; i >= 0; i --){
      queue[i].popPushRight(other);
    }
    size = 0;
    queue.clear();
  }
  void popPushLeft (L)(ref L other){
    assert(other.size + size <= other.capacity);
    for (int i = 0; i < queue.size; i ++){
      queue[i].popPushLeft(other);
    }
    size = 0;
    queue.clear();
  }
  void popPushRight (L)(size_t count, ref L other){
    assert(other.size + count <= other.capacity);
    if (count == 0) return;
    size_t idx = size - count;
    size_t i = (idx + childCapacity - queue[0].size) / childCapacity;
    size_t j = idx;
    if (i != 0) j += childCapacity - i*childCapacity - queue[0].size;
    for (size_t k = queue.size - 1; k > i; k --){
      queue[k].popPushRight(other);
    }
    queue[i].popPushRight(queue[i].size - j, other);
    size -= count;
    queue.size = i + 1;
  }
  void popPushLeft (L)(size_t count, ref L other){
    if (count == 0) return;
    assert(other.size + count <= other.capacity);
    size_t i = (count + childCapacity - queue[0].size) / childCapacity;
    size_t j = count;
    if (i != 0) j += childCapacity - i*childCapacity - queue[0].size;
    for (size_t k = 0; k < i; k ++){
      queue[k].popPushLeft(other);
    }
    queue[i].popPushLeft(j, other);
    size -= count;
    queue.size -= i;
    queue.head += i;
    if (queue.head > width + 1){
      queue.head -= width + 1;
    }
  }
  void insert (T [] arr, size_t idx){
    assert(arr.length + size <= capacity && idx < size);
    if (arr.length == 0) return;
    size_t i = (idx + childCapacity - queue[0].size)/ childCapacity;
    size_t j = idx;
    if (i != 0) j += childCapacity - i*childCapacity - queue[0].size;
    if (i == queue.size - 1){
      if (childCapacity - queue[$-1].size >= arr.length){
	queue[$-1].insert(arr, j);
	size += arr.length;
      }
      else {
	size_t endsize = size + arr.length;
	if (arr.length + j >= childCapacity){
	  size_t starti = queue.size + (arr.length - childCapacity + j) / childCapacity;
	  size_t endi = queue.size + (arr.length - childCapacity + queue[$-1].size) / childCapacity;
	  if (starti == endi){
	    this.popPushRight(size - idx, queue.indexOUtOfBounds(starti));
	  }
	  else {
	    size_t endj = (queue[$-1].size + arr.length)%childCapacity;
	    this.popPushRight(endj, queue.indexOUtOfBounds(endi));
	    this.popPushRight(queue[$-1].size - j, queue.indexOUtOfBounds(starti));
	  }
	  size_t done = 0;
	  queue[$-1].pushBack(arr, done);
	  for (size_t k = queue.size; k < starti; k ++){
	    queue.indexOUtOfBounds(k).pushFront(arr[done .. done+childCapacity]);
	    done += childCapacity;
	  }
	  queue.indexOUtOfBounds(starti).pushFront(arr[done .. $]);
	  size = endsize;
	  queue.size = endi + 1;
	}
	else {
	  this.popPushRight(queue[$-1].size + arr.length - childCapacity, queue.indexOUtOfBounds(queue.size));
	  queue[$-1].insert(arr, j);
	  size = endsize;
	  queue.size ++;
	}
      }
    }
    else if (i == 0){
      if (childCapacity - queue[0].size >= arr.length){
	queue[0].insert(arr, j);
	size += arr.length;
      }
      else {
	size_t endsize = size + arr.length;
	if (arr.length + j >= childCapacity){
	  size_t starti = (width - 1 + queue.head + queue.size - (arr.length + size - queue[$-1].size)/childCapacity) % (width + 1);
	  size_t endi = (width - 1 + queue.head + queue.size - (arr.length + size - idx - queue[$-1].size)/childCapacity) % (width + 1);
	  size_t startj = (arr.length + size - queue[$-1].size) % childCapacity;
	  size_t done;
	  if (starti == endi){
	    this.popPushLeft(idx, queue.absoluteIdx(starti));
	    done = startj - idx;
	    queue.absoluteIdx(endi).pushBack(arr[0 .. startj - idx]);
	  }
	  else {
	    this.popPushLeft(startj, queue.absoluteIdx(starti));
	    if (endi == queue.head){
	      queue[0].insert(arr, j - startj);
	      done = arr.length;
	    }
	    else {
	      this.popPushLeft(idx - startj, queue.absoluteIdx(endi));
	      done = 0;
	      queue.absoluteIdx(endi).pushBack(arr, done);
	    }
	  }
	  if (endi > queue.head){
	    for (size_t k = endi + 1; k < width + 1; k ++){
	      queue.absoluteIdx(k).pushFront(arr[done .. done + childCapacity]);
	      done += childCapacity;
	    }
	    for (size_t k = 0; k < queue.head; k ++){
	      queue.absoluteIdx(k).pushFront(arr[done .. done + childCapacity]);
	      done += childCapacity;
	    }
	  }
	  else {
	    for (size_t k = endi + 1; k < queue.head; k ++){
	      queue.absoluteIdx(k).pushFront(arr[done .. done + childCapacity]);
	      done += childCapacity;
	    }
	  }
	  queue.absoluteIdx(queue.head).pushFront(arr[done .. $]);
	  size = endsize;
	  queue.size += (width + 1 + queue.head - starti) % (width+1);
	  queue.head = starti;
	}
	else {
	  size_t shiftSize = queue[0].size + arr.length - childCapacity;
	  if (shiftSize > idx){
	    this.popPushLeft(idx, queue.indexOUtOfBounds(width));
	    queue.indexOUtOfBounds(width).pushBack(arr[0 .. shiftSize - idx]);
	    queue[0].pushFront(arr[shiftSize - idx .. $]);
	  }
	  else {
	    this.popPushLeft(shiftSize, queue.indexOUtOfBounds(width));
	    queue[0].insert(arr, j - shiftSize);
	  }
	  size = endsize;
	  queue.size ++;
	  queue.head = queue.head == 0 ? width : queue.head - 1;
	}
      }
    }
    else if (idx >= size/2){
      if (arr.length >= childCapacity){
	size_t endi = (size + arr.length + childCapacity - queue[0].size) / childCapacity;
	size_t endj = size + arr.length + childCapacity - endi*childCapacity - queue[0].size;
	size_t endsize = size+arr.length;
	size_t starti = (idx + arr.length + childCapacity - queue[0].size)/ childCapacity;
	size_t startj =  starti*childCapacity + queue[0].size - idx - arr.length;
	if (size - idx > endj){
	  this.popPushRight(endj, queue.indexOUtOfBounds(endi));
	  for (size_t k = endi-1; k > starti; k --){
	    this.popPushRight(childCapacity, queue.indexOUtOfBounds(k));
	  }
	  this.popPushRight(startj, queue.indexOUtOfBounds(starti));
	}
	else {
	  this.popPushRight(size-idx, queue.indexOUtOfBounds(endi));
	}
	size_t done = 0;
	queue[$-1].pushBack(arr, done);
	for (size_t k = queue.size; k < starti; k ++){
	  queue.indexOUtOfBounds(k).pushFront(arr[done .. done+childCapacity]);
	  done += childCapacity;
	}
	queue.indexOUtOfBounds(starti).pushFront(arr[done .. $]);
	size = endsize;
	queue.size = endi+1;
      }
      else {
	size_t endqueuesize = queue.size;
	if (queue[$-1].size + arr.length > childCapacity){
	  queue[$-1].popPushRight(queue[$-1].size + arr.length - childCapacity, queue.indexOUtOfBounds(queue.size));
	  endqueuesize ++;
	}
	for (size_t k = queue.size - 1; k > i + 1; k --){
	  queue[k-1].popPushRight(arr.length, queue[k]);
	}
	if (childCapacity - j > arr.length){
	  queue[i].popPushRight(queue[i].size - childCapacity + arr.length, queue.indexOUtOfBounds(i+1));
	  queue[i].insert(arr, j);
	}
	else {
	  queue[i].popPushRight(queue[i].size - j, queue.indexOUtOfBounds(i+1));
	  queue[i].pushBack(arr[0 .. childCapacity - j]);
	  queue.indexOUtOfBounds(i+1).pushFront(arr[childCapacity - j .. $]);
	}
	queue.size = endqueuesize;
	size += arr.length;
      }
    }
    else {
      if (arr.length >= childCapacity){
	size_t starti = (width - 1 + queue.head + queue.size - (arr.length + size - queue[$-1].size)/childCapacity) % (width + 1);
	size_t startj = (arr.length + size - queue[$-1].size) % childCapacity;
	size_t endsize = size + arr.length;
	size_t endi = (width - 1 + queue.head + queue.size - (arr.length + size - idx - queue[$-1].size)/childCapacity) % (width + 1);
	size_t endj = (idx + childCapacity - startj) % childCapacity;
	if (endj == 0){
	  endj = childCapacity;
	}
	
	if (idx > startj){
	  this.popPushLeft(startj, queue.absoluteIdx(starti));
	  if (endi < starti){
	    for (size_t k = starti+1; k < width + 1; k ++){
	      this.popPushLeft(childCapacity, queue.absoluteIdx(k));
	    }
	    for (size_t k = 0; k != endi; k ++){
	      this.popPushLeft(childCapacity, queue.absoluteIdx(k));
	    }
	  }
	  else {
	    for (size_t k = starti+1; k < endi; k ++){
	      this.popPushLeft(childCapacity, queue.absoluteIdx(k));
	    }
	  }
	  this.popPushLeft(endj, queue.absoluteIdx(endi));
	  if (endi < queue.head){
	    size_t done = 0;
	    queue.absoluteIdx(endi).pushBack(arr, done);
	    for (size_t k = endi+1; k < queue.head; k ++){
	      queue.absoluteIdx(k).pushFront(arr[done .. done+childCapacity]);
	      done += childCapacity;
	    }
	    queue[0].pushFront(arr[done .. $]);
	  }
	  else {
	    size_t done = 0;
	    queue.absoluteIdx(endi).pushBack(arr, done);
	    for (size_t k = endi+1; k < width + 1; k ++){
	      queue.absoluteIdx(k).pushFront(arr[done .. done+childCapacity]);
	      done += childCapacity;
	    }
	    for (size_t k = 0; k < queue.head; k ++){
	      queue.absoluteIdx(k).pushFront(arr[done .. done+childCapacity]);
	      done += childCapacity;
	    }
	    queue[0].pushFront(arr[done .. $]);
	  }
	}
	else {
	  this.popPushLeft(idx, queue.absoluteIdx(starti));
	  queue.absoluteIdx(starti).pushBack(arr[0 .. startj - idx]);
	  size_t done = startj - idx;
	  if (starti < queue.head){
	    for (size_t k = starti + 1; k < queue.head; k ++){
	      queue.absoluteIdx(k).pushFront(arr[done .. done+childCapacity]);
	      done += childCapacity;
	    }
	    queue[0].pushFront(arr[done .. $]);
	  }
	  else {
	    for (size_t k = starti + 1; k < width + 1; k ++){
	      queue.absoluteIdx(k).pushFront(arr[done .. done+childCapacity]);
	      done += childCapacity;
	    }
	    for (size_t k = 0; k < queue.head; k ++){
	      queue.absoluteIdx(k).pushFront(arr[done .. done+childCapacity]);
	      done += childCapacity;
	    }
	    queue[0].pushFront(arr[done .. $]);
	  }
	}
	queue.size += (width + 1 + queue.head - starti) % (width+1);
	queue.head = starti;
	size = endsize;
      }
      else {
	bool isQueueSizeIncreased = false;
	if (queue.absoluteIdx(queue.head).size + arr.length > childCapacity){
	  if (queue.head == 0){
	    queue.absoluteIdx(queue.head).popPushLeft(queue.absoluteIdx(queue.head).size + arr.length - childCapacity, queue.absoluteIdx(width));
	  }
	  else {
	    queue.absoluteIdx(queue.head).popPushLeft(queue.absoluteIdx(queue.head).size + arr.length - childCapacity, queue.absoluteIdx(queue.head - 1));
	  }
	  isQueueSizeIncreased = true;
	}
	for (size_t k = 1; k < i; k ++){
	  queue[k].popPushLeft(arr.length, queue[k-1]);
	}
	if (j > arr.length){
	  size_t popPushSize = queue[i].size - childCapacity + arr.length;
	  queue[i].popPushLeft(queue[i].size - childCapacity + arr.length, queue.indexOUtOfBounds(i-1));
	  queue[i].insert(arr, j - popPushSize);
	}
	else {
	  queue[i].popPushLeft(j, queue.indexOUtOfBounds(i-1));
	  queue[i].pushFront(arr[arr.length - j .. arr.length]);
	  queue.indexOUtOfBounds(i-1).pushBack(arr[0 .. arr.length - j]);
	}
	if (isQueueSizeIncreased){
	  queue.size ++;
	  queue.head = queue.head == 0 ? width : queue.head - 1;
	}
	size += arr.length;
      }
    }
  }
  void remove (size_t count, size_t idx){
    assert(idx + count <= size);
    size_t si = (idx + childCapacity - queue[0].size)/ childCapacity;
    size_t sj = idx;
    if (si != 0) sj += childCapacity - si*childCapacity - queue[0].size;
    size_t ei = (idx + count + childCapacity - queue[0].size)/ childCapacity;
    size_t ej = idx + count;
    if (ei != 0) ej += childCapacity - ei*childCapacity - queue[0].size;
    if (si == queue.size - 1){
      queue[$-1].remove(count, sj);
      size -= count;
    }
    else if (ei == 0){
      queue[0].remove(count, sj);
      size -= count;
    }
    else if (size - idx - count < idx){
      if (count < childCapacity){
	if (queue[si].size - sj > count){
	  queue[si].remove(count, sj);
	  for (size_t k = si + 1; k < queue.size - 1; k ++){
	    queue[k].popPushLeft(count, queue[k-1]);
	  }
	  if (queue[$-1].size > count){
	    queue[$-1].popPushLeft(count, queue[$-2]);
	  }
	  else {
	    queue[$-1].popPushLeft(queue[$-1].size, queue[$-2]);
	    queue.size --;
	  }
	}
	else {
	  queue[si].popBack(queue[si].size - sj);
	  queue[si+1].popFront(ej);
	  if (queue[si+1].size < childCapacity - sj){ //assumed that si+1 is the end
	    queue[si+1].popPushLeft(queue[si+1].size, queue[si]);
	    if (si+1 != queue.size - 1){
	      queue[si+2].popPushLeft(queue[si+2].size, queue[si+1]);
	    }
	    queue.size --;
	  }
	  else {
	    queue[si+1].popPushLeft(childCapacity-sj, queue[si]);
	    if (si+1 != queue.size - 1){
	      for (size_t k = si+2; k < queue.size - 1; k ++){
		queue[k].popPushLeft(count, queue[k-1]);
	      }
	      if (queue[$-1].size >= count){
		queue[$-1].popPushLeft(count, queue[$-2]);
	      }
	      else {
		queue[$-1].popPushLeft(queue[$-1].size, queue[$-2]);
		queue.size --;
	      }
	    }
	  }
	}
	size -= count;
      }
      else {
	queue[si].popBack(queue[si].size - sj);
	for (size_t k = si+1; k < ei; k ++){
	  queue[k].clear();
	}
	queue[ei].popFront(ej);
	size_t prevSize = queue.size;
	queue.size = si + 1;
	size = idx;
	for (size_t k = ei; k < prevSize; k ++){
	  queue.indexOUtOfBounds(k).popPushLeft(queue.indexOUtOfBounds(k).size, this);
	}
      }
    }
    else {
      if (count < childCapacity){
	if (queue[si].size - sj > count){
	  queue[si].remove(count, sj);
	  if (si != 0){
	    for (size_t k = si - 1; k > 0; k --){
	      queue[k].popPushRight(count, queue[k+1]);
	    }
	  }
	  if (queue[0].size > count){
	    queue[0].popPushRight(count, queue[1]);
	  }
	  else {
	    queue[0].popPushRight(queue[0].size, queue[1]);
	    queue.size --;
	    queue.head = queue.head == width ? 0 : queue.head + 1;
	  }
	  size -= count;
	}
	else {
	  queue[si+1].popFront(ej);
	  queue[si].popBack(count - ej);
	  if (queue[si].size < ej){
	    queue[si].popPushRight(queue[si].size, queue[si+1]);
	    queue.size --;
	    queue.head = queue.head == width ? 0 : queue.head + 1;
	  }
	  else {
	    queue[si].popPushRight(ej, queue[si+1]);
	    if (si != 0){
	      for (size_t k = si - 1; k > 0; k --){
		queue[k].popPushRight(count, queue[k+1]);
	      }
	      if (queue[0].size > count){
		queue[0].popPushRight(count, queue[1]);
	      }
	      else {
		queue[0].popPushRight(queue[0].size, queue[1]);
		queue.size --;
		queue.head = queue.head == width ? 0 : queue.head + 1;
	      }
	    }
	  }
	  size -= count;
	}
      }
      else {
	queue[si].popBack(queue[si].size - sj);
	for (size_t k = si+1; k < ei; k ++){
	  queue[k].clear();
	}
	queue[ei].popFront(ej);
	size_t prevhead = queue.head;
	queue.head = (queue.head + ei) % (width+1);
	queue.size -= ei;
	size -= idx + count;
	if (prevhead+si > width){
	  for (size_t k = prevhead + si - width - 1; k > 0; k --){
	    queue.absoluteIdx(k).popPushRight(queue.absoluteIdx(k).size, this);
	  }
	  queue.absoluteIdx(0).popPushRight(queue.absoluteIdx(0).size, this);
	  for (size_t k = width; k >= prevhead; k --){
	    queue.absoluteIdx(k).popPushRight(queue.absoluteIdx(k).size, this);
	  }
	}
	else {
	  for (size_t k = prevhead+si; k >= prevhead; k --){
	    queue.absoluteIdx(k).popPushRight(queue.absoluteIdx(k).size, this);
	  }
	}
      }
    }
  }
}

import std.random;
const int S = 10;
T min (T) (T a, T b){
  if (a > b) return b;
  return a;
}
void main (){
}


// for FixedQueue popPushRight

unittest {
  const size_t x = 100;
  FixedQueue!(int, x) f;
  FixedQueue!(int, x) s;
  for (int l = 0; l < 10000; l ++){
    size_t s1 = uniform(1, x+1, r);
    size_t s2 = uniform(1, x, r);
    f.size = s1;
    s.size = s2;
    size_t h1 = uniform(1, x, r); 
    size_t h2 = uniform(1, x, r);
    f.head = h1;
    s.head = h2;
    for (int i = 0; i < s1; i ++){
      f[i] = i+1;
    }
    for (int i = 0; i < s2; i ++){
      s[i] = i+1;
    }
    size_t count = uniform(1, min(s1, x-s2)+1, r);
    f.popPushRight(count, s);
    assert(f.size == s1-count);
    assert(s.size == s2+count);
    for (int i = 0; i < s1-count; i ++){
      assert(f[i] == i+1);
    }
    for (int i = 0; i < count; i ++){
      assert(s[i] == i+s1-count+1);
    }
    for (int i = 0; i < s2; i ++){
      assert(s[i+count] == i+1);
    }
  }
}

// for FixedQueue popPushLeft

unittest {
  const size_t x = 100;
  FixedQueue!(int, x) f;
  FixedQueue!(int, x) s;
  for (int l = 0; l < 10000; l ++){
    size_t s1 = uniform(1, x+1, r);
    size_t s2 = uniform(1, x, r);
    f.size = s1;
    s.size = s2;
    size_t h1 = uniform(1, x, r); 
    size_t h2 = uniform(1, x, r);
    f.head = h1;
    s.head = h2;
    for (int i = 0; i < s1; i ++){
      f[i] = i+1;
    }
    for (int i = 0; i < s2; i ++){
      s[i] = i+1;
    }
    size_t count = uniform(1, min(s1, x-s2)+1, r);
    f.popPushLeft(count, s);
    assert(f.size == s1-count);
    assert(s.size == s2+count);
    for (int i = 0; i < s1-count; i ++){
      assert(f[i] == i+1+count);
    }
    for (int i = 0; i < s2; i ++){
      assert(s[i] == i+1);
    }
    for (int i = 0; i < count; i ++){
      assert(s[i+s2] == i+1);
    }
  }
}

// for FixedQueue insert

unittest {
  const size_t x = 100;
  FixedQueue!(int, x) f;
  int [x] arr;
  for (int i = 0; i < x; i ++){
    arr[i] = 1001+i;
  }
  for (int l = 0; l < 10000; l ++){
    size_t s1 = uniform(1, x, r);
    f.size = s1;
    size_t h1 = uniform(1, x, r);
    f.head = h1;
    for (int i = 0; i < s1; i ++){
      f[i] = i+1;
    }
    size_t count = uniform(1, x-s1+1, r);
    size_t idx = uniform(0, s1, r);
    f.insert(arr[0 .. count], idx);
    assert(f.size == s1+count);
    for (int i = 0; i < idx; i ++){
      assert(f[i] == i+1);
    }
    for (int i = 0; i < count; i ++){
      assert(f[i+idx] == i+1001);
    }
    for (int i = 0; i < s1-idx; i ++){
      assert(f[i+idx+count] == i+1+idx);
    }
  }
}

// for FixedQueue remove

unittest {
  const size_t x = 100;
  FixedQueue!(int, x) f;
  for (int l = 0; l < 10000; l ++){
    size_t s1 = uniform(1, x, r);
    f.size = s1;
    size_t h1 = uniform(1, x, r);
    f.head = h1;
    for (int i = 0; i < s1; i ++){
      f[i] = i+1;
    }
    size_t idx = uniform(0, s1, r);
    size_t count = uniform(1, s1-idx+1, r);
    f.remove(count, idx);
    assert(f.size == s1-count);
    for (int i = 0; i < idx; i ++){
      assert(f[i] == i+1);
    }
    for (size_t i = idx; i < s1-count; i ++){
      assert(f[i] == i+count+1);
    }
  }
}

// for FixedQueue pushBack

unittest {
  const size_t x = 100;
  FixedQueue!(int, x) f;
  int [x] arr;
  for (int i = 0; i < x; i ++){
    arr[i] = 1001+i;
  }
  for (int l = 0; l < 10000; l ++){
    size_t s1 = uniform(1, x, r);
    f.size = s1;
    size_t h1 = uniform(1, x, r);
    f.head = h1;
    for (int i = 0; i < s1; i ++){
      f[i] = i+1;
    }
    size_t count = uniform(1, x-s1+1, r);
    f.pushBack(arr[0 .. count]);
    assert(f.size == s1+count);
    for (int i = 0; i < s1; i ++){
      assert(f[i] == i+1);
    }
    for (size_t i = s1; i < s1+count; i ++){
      assert(f[i] == i+1001-s1);
    }
  }
}

//for FixedQueue pushFront

unittest {
  const size_t x = 100;
  FixedQueue!(int, x) f;
  int [x] arr;
  for (int i = 0; i < x; i ++){
    arr[i] = 1001+i;
  }
  for (int l = 0; l < 10000; l ++){
    size_t s1 = uniform(1, x, r);
    f.size = s1;
    size_t h1 = uniform(1, x, r);
    f.head = h1;
    for (int i = 0; i < s1; i ++){
      f[i] = i+1;
    }
    size_t count = uniform(1, x-s1+1, r);
    f.pushFront(arr[0 .. count]);
    assert(f.size == s1+count);
    for (int i = 0; i < count; i ++){
      assert(f[i] == i+1001);
    }
    for (size_t i = count; i < s1+count; i ++){
      assert(f[i] == i+1-count);
    }
  }
}

// for FixedQueue popBack

unittest {
  const size_t x = 100;
  FixedQueue!(int, x) f;
  for (int l = 0; l < 10000; l ++){
    size_t s1 = uniform(1, x, r);
    f.size = s1;
    size_t h1 = uniform(1, x, r);
    f.head = h1;
    for (int i = 0; i < s1; i ++){
      f[i] = i+1;
    }
    size_t count = uniform(1, s1+1, r);
    f.popBack(count);
    assert(f.size == s1-count);
    for (int i = 0; i < s1-count; i ++){
      assert(f[i] == i+1);
    }
  }
}

// for FixedQueue popFront

unittest {
  const size_t x = 100;
  FixedQueue!(int, x) f;
  for (int l = 0; l < 10000; l ++){
    size_t s1 = uniform(1, x, r);
    f.size = s1;
    size_t h1 = uniform(1, x, r);
    f.head = h1;
    for (int i = 0; i < s1; i ++){
      f[i] = i+1;
    }
    size_t count = uniform(1, s1+1, r);
    f.popFront(count);
    assert(f.size == s1-count);
    for (int i = 0; i < s1-count; i ++){
      assert(f[i] == i+1+count);
    }
  }
}

// for TieredVector 2d pushFront

unittest {
  const size_t x = 100;
  for (int l = 0; l < 1000; l ++){
    size_t size = uniform(1, x*x, r);
    size_t fsize = uniform(1, min(size+1, x+1), r);
    TieredVector!(int, x, x) v;
    size_t left = size;
    v.queue.size = 1 + (size-fsize+x-1)/x;
    v.size = size;
    v.queue[0].size = fsize;
    left -= fsize;
    size_t idx = 1;
    while (left > x){
      v.queue[idx].size = x;
      left -= x;
      idx ++;
    }
    if (left != 0) v.queue[idx].size = left;
    for (int i = 0; i < cast(int)size; i ++){
      v[i] = i+1;
    }
    size_t pb = uniform(1, x*x-size+1, r);
    int [] arr;
    for (int i = 0; i < cast(int)pb; i ++){
      arr ~= 1001+i;
    }
    v.pushFront(arr);
    assert(v.size == size+arr.length);
    for (size_t i = 0; i < pb; i ++){
      assert(v[i] == i+1001);
    }
    for (size_t i = 0; i < size; i ++){
      assert(v[i+pb] == i+1);
    }
  }
}


// for TieredVector 2d pushBack

unittest {
  const size_t x = 100;
  for (int l = 0; l < 1000; l ++){
    size_t size = uniform(1, x*x, r);
    size_t fsize = uniform(1, min(size+1, x+1), r);
    TieredVector!(int, x, x) v;
    size_t left = size;
    v.queue.size = 1 + (size-fsize+x-1)/x;
    v.size = size;
    v.queue[0].size = fsize;
    left -= fsize;
    size_t idx = 1;
    while (left > x){
      v.queue[idx].size = x;
      left -= x;
      idx ++;
    }
    if (left != 0) v.queue[idx].size = left;
    for (int i = 0; i < cast(int)size; i ++){
      v[i] = i+1;
    }
    size_t pb = uniform(1, x*x-size+1, r);
    int [] arr;
    for (int i = 0; i < cast(int)pb; i ++){
      arr ~= 1001+i;
    }
    v.pushBack(arr);
    assert(v.size == size+arr.length);
    for (size_t i = 0; i < size; i ++){
      assert(v[i] == i+1);
    }
    for (size_t i = 0; i < pb; i ++){
      assert(v[i+size] == i+1001);
    }
  }
}

// for TieredVector 2d popBack

unittest {
  const size_t x = 100;
  for (int l = 0; l < 1000; l ++){
    size_t size = uniform(1, x*x, r);
    size_t fsize = uniform(1, min(size+1, x+1), r);
    TieredVector!(int, x, x) v;
    size_t left = size;
    v.queue.size = 1 + (size-fsize+x-1)/x;
    v.size = size;
    v.queue[0].size = fsize;
    left -= fsize;
    size_t idx = 1;
    while (left > x){
      v.queue[idx].size = x;
      left -= x;
      idx ++;
    }
    if (left != 0) v.queue[idx].size = left;
    for (int i = 0; i < cast(int)size; i ++){
      v[i] = i+1;
    }
    size_t count = uniform(1, size+1, r);
    v.popBack(count);
    assert(v.size == size - count);
    for (size_t i = 0; i < size-count; i ++){
      assert(v[i] == i+1);
    }
  }
}

// for TieredVector 2d popFront

unittest {
  const size_t x = 100;
  for (int l = 0; l < 1000; l ++){
    size_t size = uniform(1, x*x, r);
    size_t fsize = uniform(1, min(size+1, x+1), r);
    TieredVector!(int, x, x) v;
    size_t left = size;
    v.queue.size = 1 + (size-fsize+x-1)/x;
    v.size = size;
    v.queue[0].size = fsize;
    left -= fsize;
    size_t idx = 1;
    while (left > x){
      v.queue[idx].size = x;
      left -= x;
      idx ++;
    }
    if (left != 0) v.queue[idx].size = left;
    for (int i = 0; i < cast(int)size; i ++){
      v[i] = i+1;
    }
    size_t count = uniform(1, size+1, r);
    v.popFront(count);
    assert(v.size == size - count);
    for (size_t i = 0; i < size-count; i ++){
      assert(v[i] == i+1+count);
    }
  }
}

// for TieredVector 2d popPushRight

unittest {
  const size_t x = 100;
  int [] arr;
  for (int i = 0; i < x*x; i ++){
    arr ~= i+1;
  }
  for (int l = 0; l < 10000; l ++){
    size_t size1 = uniform(2, x*x, r);
    size_t size2 = uniform(1, x*x-1, r);
    TieredVector!(int, x, x) v1;
    // v1.queue.size = 1;
    v1.pushBack(arr[0 .. size1]);
    TieredVector!(int, x, x) v2;
    // v2.queue.size = 1;
    v2.pushBack(arr[0 .. size2]);
    size_t pushSize = uniform(1, min(x*x-size2, size1), r);
    v1.popPushRight(pushSize, v2);
    assert(v1.size == size1-pushSize);
    assert(v2.size == size2+pushSize);
    for (size_t i = 0; i < size1-pushSize; i ++){
      assert(v1[i] == i+1);
    }
    for (size_t i = size1-pushSize; i < size1; i ++){
      assert(v2[i-(size1-pushSize)] == i+1);
    }
    for (size_t i = 0; i < size2; i ++){
      assert(v2[i+pushSize] == i+1);
    }
  }
}

// for TieredVector 2d popPushLeft

unittest {
  const size_t x = 100;
  int [] arr;
  for (int i = 0; i < x*x; i ++){
    arr ~= i+1;
  }
  for (int l = 0; l < 10000; l ++){
    size_t size1 = uniform(2, x*x, r);
    size_t size2 = uniform(1, x*x-1, r);
    TieredVector!(int, x, x) v1;
    // v1.queue.size = 1;
    v1.pushBack(arr[0 .. size1]);
    TieredVector!(int, x, x) v2;
    // v2.queue.size = 1;
    v2.pushBack(arr[0 .. size2]);
    size_t pushSize = uniform(1, min(x*x-size2, size1), r);
    v1.popPushLeft(pushSize, v2);
    assert(v1.size == size1-pushSize);
    assert(v2.size == size2+pushSize);
    for (size_t i = pushSize; i < size1; i ++){
      assert(v1[i-pushSize] == i+1);
    }
    for (size_t i = 0; i < size2; i ++){
      assert(v2[i] == i+1);
    }
    for (size_t i = size2; i < size2+pushSize; i ++){
      assert(v2[i] == i-size2+1);
    }
  }
}

// for TieredVector 2d isnert

unittest {
  const size_t x = 100;
  int [] arr;
  for (int i = 0; i < x*x; i ++){
    arr ~= i+1;
  }
  for (int l = 0; l < 10000; l ++){
    size_t size = uniform(2, x*x - 1, r);
    size_t fsize = uniform(1, min(size+1, x+1), r);
    size_t offset = uniform (1, x+1, r);
    TieredVector!(int, x, x) v;
    size_t left = size;
    v.queue.size = 1 + (size-fsize+x-1)/x;
    v.queue.head = offset;
    v.size = size;
    v.queue[0].size = fsize;
    left -= fsize;
    size_t idx = 1;
    while (left > x){
      v.queue[idx].size = x;
      left -= x;
      idx ++;
    }
    if (left != 0) v.queue[idx].size = left;
    for (int i = 0; i < cast(int)size; i ++){
      v[i] = i+1;
    }
    size_t insertSize = uniform (1, x*x-size, r);
    size_t pos = uniform (1, size, r);
    v.insert(arr[0 .. insertSize], pos);
    assert(v.size == size + insertSize);
    for (int i = 0; i < pos; i ++){
      assert(v[i] == i+1);
    }
    for (int i = 0; i < insertSize; i ++){
      assert(v[i+pos] == i+1);
    }
    for (int i = 0; i < size-pos; i ++){
      assert(v[i+pos+insertSize] == i+1+pos);
    }
  }
}


// for TieredVector 2d remove

unittest {
  const size_t x = 100;
  for (int l = 0; l < 10000; l ++){
    size_t size = uniform(2, x*x - 1, r);
    size_t fsize = uniform(1, min(size+1, x+1), r);
    size_t offset = uniform (1, x+1, r);
    TieredVector!(int, x, x) v;
    size_t left = size;
    v.queue.size = 1 + (size-fsize+x-1)/x;
    v.queue.head = offset;
    v.size = size;
    v.queue[0].size = fsize;
    left -= fsize;
    size_t idx = 1;
    while (left > x){
      v.queue[idx].size = x;
      left -= x;
      idx ++;
    }
    if (left != 0) v.queue[idx].size = left;
    for (int i = 0; i < cast(int)size; i ++){
      v[i] = i+1;
    }
    size_t pos = uniform (0, size - 1, r);
    size_t removesize = uniform (1, size-pos, r);
    v.remove(removesize, pos);
    assert(v.size == size - removesize);
    for (size_t i = 0; i < pos; i ++){
      assert(v[i] == i+1);
    }
    for (int i = cast(int)(pos+removesize); i < size; i ++){
      assert(v[i-removesize] == i+1);
    }
  }
}
